defmodule Stoned.DB.UserSchema do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :credit, :float
    field :email, :string
    field :role, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :active, :boolean, default: true
    timestamps(type: :utc_datetime, autogenerate: {Stoned.Repo, :current_time, []})
  end

  def add_password_hash(changeset) do
    change(changeset, Bcrypt.add_hash(changeset.changes.password))
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:name, :credit, :email, :password, :password_hash, :active, :role])
    |> add_password_hash()
    |> validate_required([:name, :credit, :email, :password_hash])
    |> unique_constraint(:email)
  end
end
