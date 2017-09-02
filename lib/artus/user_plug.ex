defmodule Artus.UserPlug do
  import Plug.Conn
  use Phoenix.Controller

  alias Artus.Repo
  alias Artus.User

  def init(opts) do
    # opts
  end

  def call(conn, _) do
    case logged_in = get_session(conn, :logged_in) do
      true ->
        user_id = get_session(conn, :user_id)
        case Repo.get!(User, user_id) do
          nil -> assign(conn, :user, nil)
          u -> assign(conn, :user, u)
        end
      _ ->
        assign(conn, :user, nil)
    end
  end
end
