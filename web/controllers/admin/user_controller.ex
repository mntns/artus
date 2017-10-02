defmodule Artus.Admin.UserController do
  use Artus.Web, :controller
  
  import Ecto.Query
  alias Artus.User
  alias Artus.Cache

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    query = from u in User, order_by: u.name
    users = Repo.all(query)
    IO.inspect users
    render conn, "index.html", %{users: users}
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", %{changeset: changeset}
  end

  def create(conn, %{"user" => user_params}) do
    default_params = %{"admin" => false, 
                       "activated" => false, 
                       "activation_code" => UUID.uuid4}
    user_params = Map.merge(user_params, default_params)
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
         user
         |> Artus.Email.new_user_email
         |> Artus.Mailer.deliver_now 

         conn
         |> put_flash(:info, "User created successfully.")
         |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
  
  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render conn, "show.html", %{shown_user: user}
  end

  def caches(conn, %{"id" => id}) do
    user = User
           |> Repo.get!(id)
           |> Repo.preload([{:caches, :entries}])
    
    render conn, "caches.html", %{shown_user: user}
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    case user.admin do
      true ->
        conn
        |> put_flash(:error, "Admin accounts can't be deleted!")
        |> redirect(to: user_path(conn, :show, id))
      false ->
        Repo.delete!(user)
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: user_path(conn, :index))
    end
  end

  @doc "Send password reset link to user"
  def reset(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    user 
    |> Artus.Email.password_reset_email
    |> Artus.Mailer.deliver_now

    conn
    |> put_flash(:info, "Sent password reset link to user.")
    |> redirect(to: user_path(conn, :show, id))
  end


end
