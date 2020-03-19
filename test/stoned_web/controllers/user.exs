defmodule Stoned.UserControllerTest do
  use StonedWeb.ConnCase, async: false
  alias Stoned.Backoffice.Report.DataFlow
  alias Stoned.TestGenerator, as: Generator
  alias Stoned.DB.UserModel

  setup do
    Stoned.Seeds.run()
    on_exit(fn ->
      DynamicSupervisor.stop(Stoned.AccountSupervisor, reason: :shutdown)
    end)
  end

  test "Create User" do
    param = Generator.user("thiago2@gmail")

    build_conn()
    |> post("/api/user", %{"params" => param})
    |> json_response(201)
  end

  test "Backoffice Report" do
    email = "thiago@gmail"
    email2 = "thiago2@gmail"

    param = Generator.user(email)
    param2 = Generator.user(email2)

    user =
      build_conn()
      |> post("/api/user", %{"params" => param})
      |> recycle()
      |> post("/api/login", %{"email" => email, "password" => "123123"})
      |> json_response(200)

    build_conn()
    |> post("/api/user", %{"params" => param2})
    |> json_response(201)

    user_deposit =
      build_conn()
      |> Generator.put_auth(user["token"])
      |> post("/api/deposit", %{"params" => %{"value" => 100}})
      |> json_response(200)

    assert user_deposit["data"]["credit"] == 1100.0

    user_withdraw =
      build_conn()
      |> Generator.put_auth(user["token"])
      |> post("/api/withdraw", %{"params" => %{"value" => 100}})
      |> json_response(200)

    assert user_withdraw["data"]["credit"] == 1000.0

    build_conn()
    |> Generator.put_auth(user["token"])
    |> post("/api/transfer", %{"params" => %{"value" => 300, "receiver" => email2}})
    |> json_response(200)


    {:ok, now} = DateTime.now("Etc/UTC")

    admin =
      build_conn()
      |> post("/api/login", %{"email" => "stoned_admin@gmail", "password" => "admin@stoned"})
      |> json_response(200)


    report =
      build_conn()
      |> Generator.put_auth(admin["token"])
      |> post("/api/backoffice", %{"params" => %{"start_date" => "2020-03-16"}})
      |> json_response(200)

    {day, month, year} = DataFlow.generate_keys(now)

    assert Map.get(report["data"], day) == 500.0
    assert Map.get(report["data"], month) == 500.0
    assert Map.get(report["data"], year) == 500.0
  end

  test "Negative Tests" do
    email = "thiago@gmail"
    email2 = "thiago2@gmail"

    param = Generator.user(email)
    param2 = Generator.user(email2)

    build_conn()
    |> post("/api/user", %{"params" => param})
    |> recycle()
    |> post("/api/user", %{"params" => param})
    |> json_response(400)

    user2 =
      build_conn()
      |> post("/api/user", %{"params" => param2})
      |> recycle()
      |> post("/api/login", %{"email" => email2, "password" => "123123"})
      |> json_response(200)

    build_conn()
    |> Generator.put_auth(user2["token"])
    |> post("/api/withdraw", %{"params" => %{"value" => 1100}})
    |> json_response(400)

    build_conn()
    |> Generator.put_auth(user2["token"])
    |> post("/api/transfer", %{"params" => %{"value" => 1100, "receiver" => email}})
    |> json_response(400)
  end

  test "Deposit and Withdraw" do
    email = "thiago@gmail"
    email2 = "thiago2@gmail"

    param = Generator.user(email)
    param2 = Generator.user(email2)

    user =
      build_conn()
      |> post("/api/user", %{"params" => param})
      |> recycle()
      |> post("/api/login", %{"email" => email, "password" => "123123"})
      |> json_response(200)

    user2 =
      build_conn()
      |> post("/api/user", %{"params" => param2})
      |> json_response(201)

    user_deposit =
      build_conn()
      |> Generator.put_auth(user["token"])
      |> post("/api/deposit", %{"params" => %{"value" => 100}})
      |> json_response(200)

    assert user_deposit["data"]["credit"] == 1100.0

    user_withdraw =
      build_conn()
      |> Generator.put_auth(user["token"])
      |> post("/api/withdraw", %{"params" => %{"value" => 100}})
      |> json_response(200)

    assert user_withdraw["data"]["credit"] == 1000.0

    user_transfer =
      build_conn()
      |> Generator.put_auth(user["token"])
      |> post("/api/transfer", %{"params" => %{"value" => 300, "receiver" => email2}})
      |> json_response(200)

    {:ok, user2} = UserModel.get(user2["id"])

    assert user2.credit == 1300.0
    assert user_transfer["data"]["credit"] == 700.0
  end
end
