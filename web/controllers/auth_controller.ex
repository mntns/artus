defmodule Artus.AuthController do
  use Artus.Web, :controller
  import Ecto.Query
  alias Artus.User
  require Logger

  def login(conn, _params) do
    render conn, "login.html"
  end

  def auth(conn, %{"mail" => mail, "password" => password}) do
    user = get_user_by_mail(mail)

    # Check if query from DB is != nil and user exists
    if is_nil(user) do
      raise_bad_login(conn)
    end

    # Checks password
    case Comeonin.Bcrypt.checkpw(password, user.hash) do
      true ->
        Artus.EventLogger.log(:log_in, user)

        conn
        |> put_session(:logged_in, true)
        |> put_session(:user_id, user.id)
        |> redirect(to: "/")
      false ->
        raise_bad_login(conn)
    end
  end 

  def logout(conn, _params) do
    Artus.EventLogger.log(:log_out, conn.assigns.user)

    conn
    |> put_session(:logged_in, false)
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

  def forgot(conn, _params) do
    render conn, "forgot.html"
  end

  def send_reset(conn, %{"mail" => mail}) do
    case user = get_user_by_mail(mail) do
      nil ->
        conn
        |> put_flash(:error, "User not found. :(")
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

  defp raise_bad_login(conn) do
    conn
    |> put_flash(:error, "Wrong username and/or password.")
    |> redirect(to: auth_path(conn, :login))
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

  defp get_user_by_mail(mail) do
    query = from u in User, where: u.mail == ^mail
    Repo.one(query)
  end

end
