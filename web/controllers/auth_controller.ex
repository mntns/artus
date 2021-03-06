defmodule Artus.AuthController do
  use Artus.Web, :controller
  import Ecto.Query
  alias Artus.{User, EventLogger}
  alias Comeonin.Bcrypt
  alias Artus.Auth.Guardian
  
  @doc "Render login page"
  def login(conn, _params) do
    render conn, "login.html"
  end

  @doc "Logs user in"
  def auth(conn, %{"mail" => mail, "password" => password}) do
    mail
    |> authenticate_user(password)
    |> auth_reply(conn)
  end 
  
  @doc "Sends authentication response to user"
  defp auth_reply({:ok, user}, conn) do
    conn
    |> log_login(user)
    |> put_flash(:success, "Welcome back!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: "/")
  end
  defp auth_reply({:error, reason}, conn) do
    conn
    |> put_flash(:error, to_string(reason))
    |> redirect(to: auth_path(conn, :login))
  end

  @doc "Signs user out"
  def logout(conn, _params) do
    if user = conn.assigns.user do
      EventLogger.log(:auth_logout, "#{user.name} logged out")
    end
    
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Successfully logged out!")
    |> redirect(to: "/")
  end

  def activate(conn, %{"code" => code}) do
    case check_activation_code(code) do
      {:ok, user} ->
        render conn, "activate.html", %{activation_code: code, activation_user: user}
      :error ->
        conn
        |> put_flash(:error, "Invalid activation code.")
        |> redirect(to: page_path(conn, :index))
    end
  end

  @doc "Renders 'forgot password' page"
  def forgot(conn, _params) do
    render conn, "forgot.html"
  end

  def send_reset(conn, %{"mail" => mail}) do
    case user = get_user_by_mail(mail) do
      nil ->
        conn
        |> put_flash(:error, "User not found.")
        |> redirect(to: auth_path(conn, :forgot))
      x ->
        # TODO: Fix this shit and add time checking
        reset_code = UUID.uuid4()
        changeset = User.changeset(user, %{activation_code: reset_code})

        changeset
        |> Repo.update!()
        |> Artus.Email.password_reset_email()
        |> Artus.Mailer.deliver_now()

        conn
        |> put_flash(:success, "Password reset link sent successfully.")
        |> redirect(to: auth_path(conn, :forgot))
    end
  end

  def set_pass(conn, %{"code" => code, "password" => pass, "password_c" => pass_c}) do
    case check_activation_code(code) do
      {:ok, user} ->
        do_set_pass(conn, user, pass, pass_c, code)
      :error ->
        conn
        |> put_flash(:error, "Expired activation code.")
        |> redirect(to: page_path(conn, :index))
    end
  end

  defp do_set_pass(conn, user, pass, pass_c, code \\ "") do
    case pass do
      ^pass_c ->
        hash = Comeonin.Bcrypt.hashpwsalt(pass)

        user
        |> User.changeset(%{activation_code: "", activated: true, hash: hash})
        |> Repo.update!()

        Artus.EventLogger.log(:auth_reset, "#{user.name} reset their password")

        conn
        |> put_flash(:info, "Successfully set password! Please log in now.")
        |> redirect(to: auth_path(conn, :login))
      _ ->
        conn
        |> put_flash(:error, "Passwords do not match!")
        |> redirect(to: auth_path(conn, :activate, code))
    end
  end


  def reset_pass(conn, %{"code" => code, "password" => pass, "password_c" => pass_c}) do
    case check_reset_code(code) do
      {:ok, user} ->
        do_set_pass(conn, user, pass, pass_c, code)
      :error ->
        conn
        |> put_flash(:error, "Expired reset code.")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def reset(conn, %{"code" => code}) do
    case check_reset_code(code) do
      {:ok, user} ->
        render conn, "reset.html", %{reset_code: code, reset_user: user}
      :error ->
        conn
        |> put_flash(:error, "Invalid reset code.")
        |> redirect(to: page_path(conn, :index))
    end

  end

  defp log_login(conn, user) do
    Artus.EventLogger.log(:auth_login, "#{user.name} logged in")

    datetime_now = NaiveDateTime.utc_now()
    datetime_last = case is_nil(user.last_login) do
      true -> ~N[0000-01-01 00:00:00]
      false -> user.last_login
    end
    threshold = (60 * 60 * 24 * 3)
    
    changeset = Artus.User.changeset(user, %{last_login: datetime_now})
    Repo.update!(changeset)
    
    case (NaiveDateTime.diff(datetime_now, datetime_last, :seconds)) do
      x when x > threshold ->
        put_flash(conn, :tutorial, "#{user.name}")
      _ -> 
        conn
    end
  end

  defp check_activation_code(code) do
    query = from u in User,
      where: u.activated == false and u.activation_code == ^code

    case Repo.one(query) do
      nil -> :error
      x -> {:ok, x}
    end
  end

  defp check_reset_code(code) do
    query = from u in User,
      where: u.activation_code == ^code

    case Repo.one(query) do
      nil -> :error
      x -> {:ok, x}
    end
  end

  @doc "Gets user by email address"
  defp get_user_by_mail(mail) do
    query = from u in User, where: u.mail == ^mail
    Repo.one(query)
  end

  @doc "Authenticates user via email adress and password"
  defp authenticate_user(email, password) do
    case get_user_by_mail(email) do
      nil ->
        Bcrypt.dummy_checkpw()
        {:error, :invalid_credentials}
      user ->
        if Bcrypt.checkpw(password, user.hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

end
