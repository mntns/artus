defmodule Artus.Router do
  use Artus.Web, :router
  use Plug.ErrorHandler

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker
  end

  pipeline :auth do
    plug Artus.Auth.Pipeline
    plug :put_current_user
    plug :put_socket_token
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :ensure_admin do
    plug :check_admin
  end

  # Uses EmailPreviewPlug in development environment
  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  scope "/", Artus do
    pipe_through [:browser, :auth]

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

    # Entries
    get "/entries/:id", EntryController, :show
    get "/entries/:id/export", EntryController, :export
    get "/entries/:id/export/:type", EntryController, :export_type
  end

  # Routes for users
  scope "/", Artus do
    pipe_through [:browser, :auth, :ensure_auth]

    # Account
    get "/account", PageController, :account

    # Entries, user routes
    get "/entries/:id/review", EntryController, :review
    get "/entries/:id/reprint", EntryController, :reprint
    get "/entries/:id/article", EntryController, :article
    
    # Entries, owner routes
    get "/entries/:id/edit", EntryController, :edit
    get "/entries/:id/delete", EntryController, :delete
    get "/entries/:id/move/:target", EntryController, :move

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
  scope "/admin", Artus.Admin do
    pipe_through [:browser, :auth, :ensure_auth, :ensure_admin]

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

  @doc "Assigns current user to connection"
  defp put_current_user(conn, _) do
    conn
    |> assign(:user, Guardian.Plug.current_resource(conn))
  end

  @doc "Assigns websocket token to connection"
  defp put_socket_token(conn, _) do
    if current_user = conn.assigns.user do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  @doc "Checks, if assigned user has admin rights"
  defp check_admin(conn, _) do
    if conn.assigns.user.admin do
      conn
    else
      conn
      |> put_flash(:info, "You have no admin rights!")
      |> redirect(to: "/")
    end
  end

end
