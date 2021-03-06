defmodule Artus.Mixfile do
  use Mix.Project

  def project do
    [app: :artus,
     version: "1.3.9",
     elixir: "~> 1.7.3",
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
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :gettext,
                    :phoenix_ecto, :postgrex, :uuid, :crypto, :comeonin, :exjsx, :bamboo, :temp,
                    :scrivener_ecto, :scrivener_html, :retrieval, :guardian, :bcrypt_elixir,
                    :navigation_history],
    extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.5"},
     {:phoenix_pubsub, "~> 1.0"},
     {:postgrex, "~> 0.13.4"},
     {:phoenix_ecto, "~> 3.3.0"},
     {:phoenix_html, "~> 2.10.5"},
     {:phoenix_live_reload, "~> 1.1.3", only: :dev},
     {:gettext, "~> 0.14.0"},
     {:cowboy, "~> 1.1.2"},
     {:exjsx, "~> 3.2.1"},
     {:bamboo, "~> 0.8"},
     {:uuid, "~> 1.1"},
     {:temp, "~> 0.4"},
     {:retrieval, "~> 0.9.1"},
     {:scrivener_ecto, "~> 1.0"},
     {:scrivener_html, "~> 1.7"},
     {:credo, "~> 0.8", only: [:dev, :test]},
     {:distillery, "~> 1.5", runtime: false},
     {:inch_ex, "~> 0.5.6", only: :docs},
     {:guardian, "~> 1.0"},
     {:comeonin, "~> 4.0"},
     {:bcrypt_elixir, "~> 0.12"},
     {:navigation_history, "~> 0.2.2"}]
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
