defmodule Artus.CacheController do
  use Artus.Web, :controller

  import Ecto.Query
  alias Artus.Entry
  alias Artus.Cache
  alias Artus.User

  def index(conn, _params) do
    caches = User
             |> Repo.get!(conn.assigns.user.id)
             |> Ecto.assoc(:caches)
             |> Repo.all() 
             |> Enum.map(fn(cache) -> Repo.preload(cache, [:entries]) end)
    render conn, "index.html", %{caches: caches}
  end

  def new(conn, _params) do
    changeset = Cache.changeset(%Cache{})
    render conn, "new.html", %{changeset: changeset}
  end

  def create(conn, %{"cache" => cache}) do
    user = Repo.get!(User, conn.assigns.user.id)
    changeset = Ecto.build_assoc(user, :caches, %{name: cache["name"]})

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Working Cache created successfully.")
        |> redirect(to: cache_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, conn.assigns.user.id)
    # TODO: Why not get!?
    cache = Cache |> Repo.get_by(id: id) |> Repo.preload(:entries)
    render conn, "show.html", %{cache: cache}
  end

  def submit(conn, %{"id" => id}) do
    supervisor = get_supervisor(conn.assigns.user)
    cache = Cache |> Repo.get!(id) |> Repo.preload(:entries)
    render conn, "submit.html", %{cache: cache, supervisor: supervisor}
  end

  def supervisor_submit(conn, %{"id" => id, "supervisor" => supervisor_id, "comment" => comment}) do
    cache = Cache |> Repo.get!(id) |> Repo.preload(:user)
    supervisor = Repo.get!(User, supervisor_id)
    
    send_transfer_mail(conn.assigns.user, supervisor, cache, comment)
    reassign_cache(cache, supervisor)

    conn
    |> put_flash(:info, "Working Cache submitted successfully.")
    |> redirect(to: cache_path(conn, :index))
  end

  def down(conn, %{"id" => id}) do
    subordinates = get_subordinates(conn.assigns.user)
    cache = Cache |> Repo.get!(id) |> Repo.preload(:entries)
    render conn, "down.html", %{cache: cache, subordinates: subordinates}
  end

  def send_down(conn, %{"id" => id, "subordinate" => subordinate_id, "comment" => comment}) do
    cache = Cache |> Repo.get!(id) |> Repo.preload(:user)
    subordinate = Repo.get!(User, subordinate_id)

    send_transfer_mail(conn.assigns.user, subordinate, cache, comment)
    reassign_cache(cache, subordinate)

    conn
    |> put_flash(:info, "Working Cache sent to a subordinate successfully.")
    |> redirect(to: cache_path(conn, :index))
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
    query = from u in User,
            where: u.branch == ^user.branch and u.level == ^(user.level - 1)
    Repo.one(query)
  end

  defp get_subordinates(user) do
    query = from u in User,
            where: u.branch == ^user.branch and u.level == ^(user.level + 1)
    Repo.all(query)
  end

  defp publish_entry(entry) do
    entry = entry |> Repo.preload(:cache) |> Repo.preload(:bibliograph)
    changeset = Entry.changeset(entry, %{cache: nil, public: true})
    Repo.update!(changeset)
  end

  def publish(conn, %{"id" => id}) do
    cache = Cache
            |> Repo.get!(id)
            |> Repo.preload(:entries)

    Enum.map(cache.entries, &publish_entry(&1))
    Repo.delete(cache)

    conn
    |> put_flash(:info, "Successfully published cache '#{cache.name}'!")
    |> redirect(to: cache_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    cache = Repo.get!(Cache, id)
    Repo.delete!(cache)
    
    conn
    |> put_flash(:info, "Cache deleted successfully.")
    |> redirect(to: cache_path(conn, :index))
  end
end
