defmodule Artus.CacheController do
  use Artus.Web, :controller
  
  import Ecto.Query
  alias Artus.{Entry, Cache, User, Logger}

  @doc "Shows all working caches by current user"
  def index(conn, _params) do
    caches = get_caches_by_user(conn.assigns.user)
    render conn, "index.html", %{caches: caches}
  end

  @doc "Shows form to create new working cache"
  def new(conn, _params) do
    changeset = Cache.changeset(%Cache{})
    render conn, "new.html", %{changeset: changeset}
  end

  @doc "Creates new working cache"
  def create(conn, %{"cache" => cache}) do
    changeset = Ecto.build_assoc(conn.assigns.user, :caches, %{name: cache["name"]})

    case Repo.insert(changeset) do
      {:ok, new_cache} ->
        Artus.EventLogger.log(
          :cache_create,
          "#{conn.assigns.user.name} created the working cache '#{new_cache.name}' (##{new_cache.id})")

        conn
        |> put_flash(:info, "Working Cache created successfully.")
        |> redirect(to: cache_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  @doc "Shows working cache by ID with redirect alert"
  def show(conn, %{"id" => id, "success" => type}) do
    message = case type do
      "edit" -> "Successfully edited entry!"
      "create" -> "Successfully created entry!"
    end

    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    conn
    |> put_flash(:info, message)
    |> render("show.html", %{cache: cache})
  end

  @doc "Shows working cache by ID"
  def show(conn, %{"id" => id}) do
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    render conn, "show.html", %{cache: cache}
  end

  @doc "Shows page for sending cache upward"
  def up(conn, %{"id" => id}) do
    supervisors = get_supervisors(conn.assigns.user)
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    render conn, "up.html", %{cache: cache, supervisors: supervisors}
  end
  
  @doc "Shows page for sending cache downward"
  def down(conn, %{"id" => id}) do
    subordinates = get_subordinates(conn.assigns.user)
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    render conn, "down.html", %{cache: cache, subordinates: subordinates}
  end

  @doc "Sends working cache to recipient"
  def send(conn, %{"id" => id, "direction" => _direction, "recipient" => recipient, "comment" => comment}) do
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    r_user = Repo.get!(User, recipient)

    Enum.each(cache.entries, &reassign(&1, r_user))
    send_transfer_mail(conn.assigns.user, r_user, cache, comment)
    reassign(cache, r_user)

    Artus.EventLogger.log(:cache_send, "#{conn.assigns.user.name} sent the working cache '#{cache.name}' to #{r_user.name}")

    conn
    |> put_flash(:info, "Working Cache was sent successfully.")
    |> redirect(to: cache_path(conn, :index))
  end

  @doc "Publishes all entries in cache and deletes it"
  def publish(conn, %{"id" => id}) do
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)

    Enum.each(cache.entries, &publish_entry(&1))
    Repo.delete(cache)

    Artus.EventLogger.log(:cache_publish, "#{conn.assigns.user.name} published the working cache '#{cache.name}' (#{cache.id})")
    Artus.FastSearchServer.rebuild()

    conn
    |> put_flash(:info, "Successfully published the Working Cache '#{cache.name}'!")
    |> redirect(to: cache_path(conn, :index))
  end

  @doc "Delete working cache including all its entries"
  def delete(conn, %{"id" => id}) do
    cache = Repo.get!(Cache, id)
    Repo.delete!(cache)

    Artus.EventLogger.log(:cache_delete, "#{conn.assigns.user.name} delete the working cache '#{cache.name}' (#{cache.id})")

    conn
    |> put_flash(:info, "Cache deleted successfully.")
    |> redirect(to: cache_path(conn, :index))
  end


  @doc "Fetches all the working caches of a specific user"
  defp get_caches_by_user(user) do
    user
    |> Ecto.assoc(:caches)
    |> Repo.all()
    |> Enum.map(fn(cache) -> Repo.preload(cache, [:entries]) end)
  end

  @doc "Sends cache transfer mail"
  defp send_transfer_mail(from_user, user, cache, comment) do
    from_user
    |> Artus.Email.transfer_cache_email(user, cache, comment)
    |> Artus.Mailer.deliver_now
  end

  @doc "Fetches supervisors of user"
  defp get_supervisors(user) do
    query = case user.level do
      x when x == 2 ->
        from u in User, where: u.level == 1
      x when x != 2 ->
        from u in User,
        where: u.branch == ^user.branch and u.level == ^(user.level - 1)
    end
    Repo.all(query)
  end

  @doc "Fetches subordinates of user"
  defp get_subordinates(user) do
    query = case user.level do
      x when x == 1 -> 
        from u in User, where: u.level == 2
      x when x != 1 ->
        from u in User,
        where: u.branch == ^user.branch and u.level == ^(user.level + 1)
    end
    Repo.all(query)
  end

  @doc "Makes entry public and removes it from cache"
  defp publish_entry(entry) do
    p_entry = Repo.preload(entry, [:cache, :user])
    changeset = Entry.publish_changeset(p_entry)
    Repo.update!(changeset)
  end

  @doc "Reassigns entry/cache to new user"
  defp reassign(object, recipient) do
    object
    |> Repo.preload(:user)
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:user, recipient)
    |> Repo.update!()
  end
end
