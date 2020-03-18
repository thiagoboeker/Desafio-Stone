defmodule Stoned.Banking.AccountAPI do
  @moduledoc """
  API de acesso a conta do Cliente em `Stoned.Banking.Account`
  """
  alias Stoned.Banking.Account

  @doc """
  Checa o Registry se o usuario ja se encontra com processo ativo.

  Caso nao esteja ativo, starta um processo com o DynamicSupervisor.
  """
  def lookup(email) do
    case Registry.lookup(Registry.Accounts, email) do
      [{pid, _}] -> {:ok, pid}
      _ -> DynamicSupervisor.start_child(Stoned.AccountSupervisor, {Account, email})
    end
  end
  
  def start(email) do
    lookup(email)
  end

  def deposit(pid, value) do
    GenServer.call(pid, {:deposit, value})
  end

  def withdraw(pid, value) do
    GenServer.call(pid, {:withdraw, value})
  end

  def active(pid) do
    GenServer.call(pid, :active)
  end

  def receive(pid: pid, from: from, value: value) do
    GenServer.cast(pid, {:receive, from, value})
  end

  def transfer(pid, %{value: value, to: email} = payload) do
    GenServer.call(pid, {:transfer, payload})
  end
end
