defmodule Artus.ReleaseTasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:artus)
    path = Application.app_dir(:artus, "priv/repo/migrations")
    Ecto.Migrator.run(Artus.Repo, path, :up, all: true)
    :init.stop()
  end
end
