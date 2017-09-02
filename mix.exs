defmodule Artus.Mixfile do
  use Mix.Project

  def project do
    [app: :artus,
     version: "1.2.0",
     elixir: "~> 1.5.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Artus, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :uuid, :crypto, :comeonin, :exjsx, :bamboo, 
                    :not_markdown]] 
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_ecto, "~> 3.0-rc"},
     {:phoenix_html, "~> 2.4"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:comeonin, "~> 2.4"},
     {:exjsx, "~> 3.2.0"},
     {:not_markdown, "~> 0.0.1"},
     {:bamboo, "~> 0.8"},
     {:uuid, "~> 1.1"},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:distillery, "~> 1.4", runtime: false}]
     #{:hackney, "~> 1.6.5", override: true}]
     #{:certifi, "~> 0.7.0", override: true}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
