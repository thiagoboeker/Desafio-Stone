defmodule Stoned.DB.Report do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :start_date, :utc_datetime
  end

  def changeset(changeset, params) do
    params = Map.update(params, "start_date", "0000-00-00", &(&1 <> " 00:00:00"))

    parse_changeset =
      fn
        %Ecto.Changeset{valid?: true} = ch -> {:ok, apply_changes(ch)}
        ch -> {:error, ch}
      end

    changeset
    |> cast(params, [:start_date])
    |> validate_required([:start_date])
    |> parse_changeset.()
  end
end
