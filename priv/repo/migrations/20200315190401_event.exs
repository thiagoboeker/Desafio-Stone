defmodule Stoned.Repo.Migrations.Event do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :uid, :string
      add :value, :float
      add :type, :string
      add :error, :string
      add :date, :utc_datetime
      add :data, :jsonb
      add :user_id, references(:users)
    end

    create unique_index(:events, [:uid])
  end
end
