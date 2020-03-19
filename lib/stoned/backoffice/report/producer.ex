defmodule Stoned.Backoffice.Report.DataProducer do
  @moduledoc """
    Produtor Genstage para relatorio
  """
  use GenStage
  alias Stoned.DB.EventsModel

  def start_link(data) do
    GenStage.start_link(__MODULE__, data, name: __MODULE__)
  end

  @doc """
  Valor utilizado para indicar o esgotamento dos eventos para serem processados.
  """
  def empty_event() do
    :empty
  end

  @doc false
  def init(data) do
    # Busca o primeiro evento baseado na data passada como parametro para gravar
    starter = EventsModel.first_event(data.from)
    {:producer, %{data: data, point_id: starter.id}}
  end

  @doc """
  Funcao para atender a demanda dos consumidores

  Recebe os eventos gerados atraves da consulta em `EventsModel.fetch_events/2` e a demanda.

  Se identificar que o numero de eventos obtidos foi menor do que a demanda, completa a demanda
  com `:empty_event` en entao sinaliza atraves de `GenStage.async_info/2` para encerrar o
  produtor e assim encerrar o `Flow` associado a ele.
  """
  def meet_demand(events, demand) do
    case Enum.count(events) do
      count when count < demand ->
        GenStage.async_info(self(), :terminate)
        events ++ List.duplicate(empty_event(), demand - count)
      _ -> events
    end
  end

  @doc false
  def handle_demand(demand, %{point_id: id} = state) do
    events =
      id
      |> EventsModel.fetch_events(demand)
      |> meet_demand(demand)
    # Atualiza point_id para pular para o proximo id de eventos apos a demanda atual
    {:noreply, events, %{state | point_id: id + demand}}
  end

  @doc false
  def handle_info(:terminate, state) do
    {:stop, :shutdown, state}
  end
end
