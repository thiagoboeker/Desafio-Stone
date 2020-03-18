defmodule Stoned.Banking.Account do
  @moduledoc """
  Conta do usuario para Depositos, Saques e Transferencias.
  """
  use GenServer

  alias Stoned.Banking.Command
  alias Stoned.Banking.Aggregate
  alias Stoned.DB.UserModel
  alias Stoned.Banking.AccountAPI
  alias Stoned.DB.EventsModel

  @doc false
  def start_link(email) do
    GenServer.start_link(__MODULE__, email, name: {:via, Registry, {Registry.Accounts, email}})
  end

  @doc false
  def init(email) do
    with {:ok, user} <- UserModel.get_by_email(email) do
      {:ok, user}
    end
  end

  @doc """
  Funcao que opera com o comportamento basico das operacoes
  """
  def operate(state, type, value) do
    {:ok, datetime} = DateTime.now("Etc/UTC")

    command = %Command{value: value, type: type, date: datetime}

    {:ok, event} = event_data =
      state
      |> Aggregate.generate_event(command)
      |> EventsModel.create()

    case event.error do
      nil ->
        {:ok, new_state} =
          event_data
          |> Aggregate.mutate_state(state)
          |> UserModel.mutate_state()
        {:reply, {:ok, new_state}, new_state}
      error ->
        {:reply, {:error, error}, state}
    end
  end

  @doc """
  Cast ativado para realizar transferencias

  Esse cast visa efetuar o recebimento de uma transferencia
  """
  def handle_cast({:receive, from, value}, state) do
    {_, {:ok, new_state}, _} = operate(Map.put(state, :from, from), "receive", value)
    {:noreply, new_state}
  end

  @doc false
  def handle_call({:deposit, value}, _from, state) do
    operate(state, "deposit", value)
  end

  @doc false
  def handle_call({:withdraw, value}, _from, state) do
    operate(state, "withdraw", value)
  end

  @doc false
  def handle_call(:active, _from, state) do
    {:reply, {:ok, %{active: state.active}}, state}
  end

  @doc false
  def handle_call({:transfer, %{value: value, to: receiver_email}}, _from, %{email: email} = state) when email != receiver_email do
    # 1. Starta o recebedor
    # 2. Checa se ele se encontra ativo
    #   Envia :receive para o recebdor
    #   operate(state, "transfer", value) na verdade age como um saque do valor
    #   transferido
    with {:ok, receiver} <- AccountAPI.start(receiver_email),
         {:ok, %{active: true}} <- AccountAPI.active(receiver) do
      AccountAPI.receive(pid: receiver, from: state.email, value: value)
      operate(state, "transfer", value)
    end
  end
end
