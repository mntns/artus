use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :artus, Artus.Endpoint,
  http: [port: 4000],
  url: [host: "localhost"],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                   cd: Path.expand("../", __DIR__)]]

# Watch static and templates for browser reloading.
config :artus, Artus.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$},
      # Artus
      ~r{lib/artus/*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :artus, Artus.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "artus_dev",
  hostname: "localhost",
  pool_size: 10,
  pool_timeout: 20_000

# Config LocalAdapter for developement environment
config :artus, Artus.Mailer,
  adapter: Bamboo.LocalAdapter

# Configure Guardian
config :artus, Artus.Auth.Guardian,
  issuer: "artus",
  secret_key: "5z5Elpgv27fQobqPAUfK5EqzgXKF1YCX9UGbV6uBJ31V6rPPbX3lvvWLcsXaomx6"
