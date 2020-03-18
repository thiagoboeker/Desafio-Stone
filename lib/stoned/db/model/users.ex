defmodule Stoned.DB.UserModel do
  @moduledoc false
  alias Stoned.DB.UserSchema
  alias Stoned.Repo
  alias Stoned.Banking.State
  import Ecto.Changeset

  def create(params) do
    %UserSchema{}
    |> change(%{})
    |> put_change(:credit, 1000.0)
    |> put_change(:role, "USER")
    |> UserSchema.changeset(params)
    |> Repo.insert()
  end

  def mutate_state(user) do
    Repo.update(user)
  end

  def get_by_email(email) do
    case Repo.get_by(UserSchema, email: email) do
      nil -> {:error, nil}
      user -> {:ok, user}
    end
  end

  def get(id) do
    case Repo.get(UserSchema, id) do
      nil -> {:error, nil}
      user -> {:ok, user}
    end
  end
end
