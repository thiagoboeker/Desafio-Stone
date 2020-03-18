defmodule Stoned.BankingTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias Stoned.Banking.AccountAPI
  alias Stoned.DB.UserModel

  import ExUnit.Callbacks

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Stoned.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Stoned.Repo, {:shared, self()})
    params = %{name: "Thiago", email: "thiago@gmail.com", credit: 0}

    {:ok, user} = UserModel.create(params)
    {:ok, pid} = AccountAPI.start(user.email)

    on_exit(fn ->
      DynamicSupervisor.terminate_child(Stoned.AccountSupervisor, pid)
    end)

    {:ok, %{user: pid}}
  end

  test "Deposit and Withdraw", %{user: pid} do
    {:ok, state} = AccountAPI.deposit(pid, 100)

    assert state.credit == 100

    {:ok, state} = AccountAPI.withdraw(pid, 100)

    assert state.credit == 0
  end
end
