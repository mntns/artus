defmodule Artus.Router do
  use Artus.Web, :router
  use Plug.ErrorHandler
  
  @doc "Assigns :user do conn"
  pipeline :artus_conn do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    
    plug Artus.UserPlug
    plug :put_user_token
  end

  @doc "Checks if :user is assigned"
  pipeline :artus_user do
    plug :check_user
  end

  @doc "Checks if assigned :user is admin"
  pipeline :artus_admin do
    plug :check_admin
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  scope "/", Artus do
    pipe_through :artus_conn

    # General routes
    get "/", PageController, :index
    get "/nojs", PageController, :nojs
    get "/noie", PageController, :noie
    get "/about", PageController, :about
    get "/imprint", PageController, :imprint
    get "/feedback", PageController, :feedback
    post "/feedback", PageController, :submit_feedback
    get "/tutorial", PageController, :tutorial

    # Query
    get "/advanced", QueryController, :advanced
    get "/search", QueryController, :search
    post "/advanced-search", QueryController, :advanced_search
    get "/query/:id", QueryController, :query
    post "/query/:id", QueryController, :query_sort

    # Authentication
    get "/login", AuthController, :login
    post "/auth", AuthController, :auth
    get "/logout", AuthController, :logout
    get "/activate/:code", AuthController, :activate
    get "/forgot", AuthController, :forgot
    post "/send_reset", AuthController, :send_reset
    post "/set_pass/:code", AuthController, :set_pass
    post "/reset_pass/:code", AuthController, :reset_pass
    get "/reset/:code", AuthController, :reset

    # TODO: User guardian for auth
    # TODO: Refactor export (JSON export)

    # Entries
    get "/entries/:id", EntryController, :show
    get "/entries/:id/export", EntryController, :export
    get "/entries/:id/export/:type", EntryController, :export_type

    scope "/" do
      pipe_through :artus_user

      # Account
      get "/account", PageController, :account

      # Entries
      get "/entries/:id/review", EntryController, :review
      get "/entries/:id/edit", EntryController, :edit
      get "/entries/:id/article", EntryController, :article
      get "/entries/:id/reprint", EntryController, :reprint
      get "/entries/:id/delete", EntryController, :delete
      get "/entries/:id/move/:target", EntryController, :move
      post "/entries/:id/link", EntryController, :link
      get "/entries/:id/remove_link/:target", EntryController, :remove_link

      # Input form
      get "/input/:cache", InputController, :input
      get "/input", InputController, :input

      # Working caches
      resources "/caches", CacheController, except: [:delete]
      get "/caches/:id/delete", CacheController, :delete
      get "/caches/:id/up", CacheController, :up
      get "/caches/:id/down", CacheController, :down
      get "/caches/:id/publish", CacheController, :publish
      post "/caches/:id/send/:direction", CacheController, :send
    end

    # Admin routes
    scope "/admin", Admin do
      pipe_through :artus_user
      pipe_through :artus_admin

      get "/", PageController, :index
      get "/stats", PageController, :stats
      get "/logs", PageController, :logs
      get "/notice", PageController, :notice
      post "/set_notice", PageController, :set_notice
      get "/backup", PageController, :backup

      # Tags
      get "/tags", TagController, :index

      # Users
      resources "/users", UserController, except: [:delete]
      get "/users/:id/delete", UserController, :delete
      get "/users/:id/reset", UserController, :reset
      get "/users/:id/caches", UserController, :caches

      # Abbreviations
      resources "/abbreviations", AbbreviationController, except: [:delete]
      get "/abbreviations/:id/delete", AbbreviationController, :delete
    end
  end

  defp check_admin(conn, _) do
    case conn.assigns.user.admin do
      true -> conn
      _ -> conn |> put_flash(:info, "You have no admin rights!") |> redirect(to: "/")
    end
  end

  defp check_user(conn, _) do
    case conn.assigns.user do
      nil -> conn |> put_flash(:info, "Please log in.") |> redirect(to: "/")
      _ -> conn
    end
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns.user do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
