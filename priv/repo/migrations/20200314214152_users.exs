defmodule Stoned.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :credit, :float
      add :password_hash, :string
      add :active, :boolean, default: true
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
