defmodule Artus do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Artus.Endpoint, []),
      # Start the Ecto repository
      supervisor(Artus.Repo, []),
      
      # Start workers for artus
      worker(Artus.DefinitionManager, []),
      worker(Artus.EntryCache, []),
      worker(Artus.QueryRunner, []),
      worker(Artus.EventLogger, []),
      worker(Artus.FastSearchServer, [])
    ]

    opts = [strategy: :one_for_one, name: Artus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Artus.Endpoint.config_change(changed, removed)
    :ok
  end
end
