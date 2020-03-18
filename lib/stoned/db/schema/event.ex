defmodule Stoned.DB.EventSchema do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Stoned.DB.UserSchema

  schema "events" do
    field :uid, :string
    field :value, :float
    field :type, :string
    field :error, :string
    field :date, :utc_datetime
    field :data, :map
    belongs_to :user, UserSchema
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:uid, :value, :type, :error, :date, :data, :user_id])
    |> validate_required([:uid, :value, :type])
    |> unique_constraint(:uid)
  end
end
