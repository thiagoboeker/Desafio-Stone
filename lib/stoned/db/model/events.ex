defmodule Stoned.DB.EventsModel do
  @moduledoc false

  alias Stoned.DB.EventSchema
  alias Stoned.Repo
  alias Stoned.Banking.Event
  import Ecto.Query

  def create(%Event{} = event) do
    params = Map.from_struct(event)

    %EventSchema{}
    |> EventSchema.changeset(params)
    |> Repo.insert()
  end

  def first_event(start_date) do
    EventSchema
    |> where([e], e.date >= ^start_date)
    |> first()
    |> Repo.one()
  end

  def fetch_events(point_id, limit) do
    deposit_filter = dynamic([e], e.type == "deposit_requested" and e.id >= ^point_id)
    withdraw_filter = dynamic([e], e.type == "withdraw_requested" and e.id >= ^point_id)
    transfer_filter = dynamic([e], e.type == "transfer_requested" and e.id >= ^point_id)
    EventSchema
    |> where(^dynamic([e], ^deposit_filter or ^withdraw_filter or ^transfer_filter))
    |> limit(^limit)
    |> Repo.all()
  end
end
