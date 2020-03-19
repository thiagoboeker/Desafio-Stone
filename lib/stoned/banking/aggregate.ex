defmodule Stoned.Banking.Event do
  @moduledoc false

  alias Stoned.Repo

  defstruct user_id: nil, uid: nil, value: 0, type: nil, error: nil, date: nil, data: %{}

  def generate(user_id: user_id, value: value, type: type, date: date, data: data) do
    %__MODULE__{
      user_id: user_id,
      value: value,
      type: type,
      date: date,
      data: data,
      uid: Repo.generate_event_id()
    }
  end

  def generate(user_id: user_id, type: type, error: error, date: date, data: data) do
    %__MODULE__{
      user_id: user_id,
      type: type,
      error: error,
      date: date,
      uid: Repo.generate_event_id(),
      data: data
    }
  end
end

defmodule Stoned.Banking.Command do
  @moduledoc false
  defstruct value: 0, from: nil, date: nil, type: nil
end

defmodule Stoned.Banking.Aggregate do
  @moduledoc """
  Modulo agregador das regras de negocio e funcionalidades do serviço
  """

  alias Stoned.Banking.Event
  alias Stoned.DB.EventSchema
  alias Stoned.Banking.Command
  alias Stoned.DB.UserSchema
  import Ecto.Changeset

  @doc """
  Funcao que realiza depositos

  Funcao primaria que credita o estado da conta do cliente
  """
  def deposit(%UserSchema{} = state, value), do: change(state, credit: state.credit + value)

  @doc """
  Funcao que realiza saques

  Funcao primaria que deduz valores do estado da conta do cliente
  """
  def withdraw(%UserSchema{} = state, value), do: change(state, credit: state.credit - value)

  @doc false
  def generate_event(state, %Command{type: "deposit"} = command) do
    with true <- command.value > 0 do
      Event.generate(
        user_id: state.id,
        value: command.value,
        type: "deposit_requested",
        date: command.date,
        data: %{}
      )
    end
  end

  @doc false
  def generate_event(state, %Command{type: "withdraw"} = command) do
    # Cliente precisa ter um saldo maior que o valor do saque
    case state.credit - command.value >= 0 do
      true ->
        Event.generate(
          user_id: state.id,
          value: command.value,
          type: "withdraw_requested",
          date: command.date,
          data: %{}
        )
      _ ->
        Event.generate(
          user_id: state.id,
          type: "withdraw_refused",
          error: "Insuficient resources for this operation",
          date: command.date,
          data: %{credit: state.credit}
        )
    end
  end

  @doc false
  def generate_event(state, %Command{type: "transfer"} = command) do
    # Cliente precisa ter um saldo maior do que o valor da transferencia
    case state.credit - command.value >= 0 do
      true ->
        Event.generate(
          user_id: state.id,
          value: command.value,
          type: "transfer_requested",
          date: command.date,
          data: %{}
        )
      _ ->
        Event.generate(
          user_id: state.id,
          type: "transfer_refused",
          error: "Insuficient resources for this operation",
          date: command.date,
          data: %{credit: state.credit}
        )
    end
  end

  @doc false
  def generate_event(state, %Command{type: "receive"} = command) do
    Event.generate(
      user_id: state.id,
      value: command.value,
      type: "received",
      date: command.date,
      data: %{}
    )
  end

  @doc false
  def mutate_state({:ok, %EventSchema{type: "received"} = event}, state) do
    # Recebimentos sao encarados como depositos para mutar o estado
    deposit(state, event.value)
  end

  def mutate_state({:ok, %EventSchema{type: "transfer_requested"} = event}, state) do
    # Transferencias sao encaradas primariamente como saques para mutar o estado
    withdraw(state, event.value)
  end

  @doc false
  def mutate_state({:ok, %EventSchema{type: "withdraw_requested"} = event}, state) do
    withdraw(state, event.value)
  end

  @doc false
  def mutate_state({:ok, %EventSchema{type: "deposit_requested"} = event}, state) do
    deposit(state, event.value)
  end

  @doc false
  def mutate_state({:ok, %EventSchema{error: error}}, state) when not is_nil(error) do
    change(state, %{})
  end
end
