defmodule Stoned.Release do
  @moduledoc """
    Modulo para auxiliar nas releases
  """
  @app :stoned

  def migrate() do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @dof false
  def seeds() do
    Application.load(@app)
    {:ok, _} = Application.ensure_all_started(@app)
    Stoned.Seeds.run()
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def repos() do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
