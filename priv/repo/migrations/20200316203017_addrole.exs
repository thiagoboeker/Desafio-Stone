defmodule Stoned.Repo.Migrations.Addrole do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string
    end
  end
end
