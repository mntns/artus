defmodule Artus.CacheController do
  use Artus.Web, :controller
  import Ecto.Query
  alias Artus.{Entry, Cache, User, Logger}

  @doc "Show all working caches by current user"
  def index(conn, _params) do
    caches = get_caches_by_user(conn.assigns.user)
    render conn, "index.html", %{caches: caches}
  end

  @doc "Show form to create new working cache"
  def new(conn, _params) do
    changeset = Cache.changeset(%Cache{})
    render conn, "new.html", %{changeset: changeset}
  end

  @doc "Create new working cache"
  def create(conn, %{"cache" => cache}) do
    changeset = Ecto.build_assoc(conn.assigns.user, :caches, %{name: cache["name"]})

    case Repo.insert(changeset) do
      {:ok, new_cache} ->
        Logger.info("Created new working cache '#{new_cache.name}'", 
                    new_cache.id, 
                    conn.assigns.user.id)

        conn
        |> put_flash(:info, "Working Cache created successfully.")
        |> redirect(to: cache_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  @doc "Show working cache by ID"
  def show(conn, %{"id" => id}) do
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    render conn, "show.html", %{cache: cache}
  end

  @doc "Show page for sending cache upward"
  def up(conn, %{"id" => id}) do
    supervisor = get_supervisor(conn.assigns.user)
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    render conn, "up.html", %{cache: cache, supervisor: supervisor}
  end
  
  @doc "Show page for sending cache downward"
  def down(conn, %{"id" => id}) do
    subordinates = get_subordinates(conn.assigns.user)
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    render conn, "down.html", %{cache: cache, subordinates: subordinates}
  end

  @doc "Send working cache to recipient"
  def send(conn, %{"id" => id, "direction" => _direction, "recipient" => recipient, "comment" => comment}) do
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)
    r_user = Repo.get!(User, recipient)

    Enum.each(cache.entries, &move_entry(&1, r_user))
    send_transfer_mail(conn.assigns.user, r_user, cache, comment)
    reassign_cache(cache, r_user)

    Logger.info("Sent cache to user ##{recipient}", cache.id, conn.assigns.user.id)

    conn
    |> put_flash(:info, "Working Cache was sent successfully.")
    |> redirect(to: cache_path(conn, :index))
  end

  @doc "Publish all entries in cache and delete it"
  def publish(conn, %{"id" => id}) do
    cache = Cache |> Cache.with_entries() |> Repo.get!(id)

    Enum.each(cache.entries, &publish_entry(&1))
    Repo.delete(cache)

    Logger.info("Published cache '#{cache.name}'", cache.id, conn.assigns.user.id)

    conn
    |> put_flash(:info, "Successfully published the Working Cache '#{cache.name}'!")
    |> redirect(to: cache_path(conn, :index))
  end

  @doc "Delete working cache including all its entries"
  def delete(conn, %{"id" => id}) do
    cache = Repo.get!(Cache, id)
    Repo.delete!(cache)

    Logger.info("Deleted cache '#{cache.name}'", cache.id, conn.assigns.user.id)

    conn
    |> put_flash(:info, "Cache deleted successfully.")
    |> redirect(to: cache_path(conn, :index))
  end

  defp get_caches_by_user(user) do
    user
    |> Ecto.assoc(:caches)
    |> Repo.all()
    |> Enum.map(fn(cache) -> Repo.preload(cache, [:entries]) end)
  end

  defp send_transfer_mail(from_user, user, cache, comment) do
    from_user
    |> Artus.Email.transfer_cache_email(user, cache, comment)
    |> Artus.Mailer.deliver_now
  end

  defp reassign_cache(cache, target_user) do
    cache 
    |> Repo.preload(:user)
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:user, target_user)
    |> Repo.update!()
  end

  defp get_supervisor(user) do
    query = case user.level do
      x when x == 2 ->
        from u in User, where: u.level == 1
      x when x != 2 ->
        from u in User,
        where: u.branch == ^user.branch and u.level == ^(user.level - 1)
    end
    Repo.one(query)
  end

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

  defp publish_entry(entry) do
    p_entry = Repo.preload(entry, :cache)
    changeset = Entry.changeset(p_entry, %{cache: nil, public: true})
    Repo.update!(changeset)
  end

  defp move_entry(entry, recipient) do
    entry
    |> Repo.preload(:user)
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:user, recipient)
    |> Repo.update!()
  end
end
