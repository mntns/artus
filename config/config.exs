use Mix.Config

# Configures the endpoint
config :artus, Artus.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "WXptf2mloqkTth6Sq/rWnGeiJqlTrLYHE0ZCdvajHAOUImJ2svY8LzDCA1+nxzHv",
  render_errors: [view: Artus.ErrorView, accepts: ~w(html), layout: false],
  pubsub: [name: Artus.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false


# Ecto
config :artus, ecto_repos: [Artus.Repo]

# Scrivener HTML
config :scrivener_html,
  routes_helper: Artus.Router.Helpers,
  view_style: :bootstrap_v4
