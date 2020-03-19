defmodule StonedWeb.UserController do
  @moduledoc false

  use StonedWeb, :controller
  alias Stoned.DB.UserModel
  alias Stoned.Banking.AccountAPI
  alias Stoned.DB.Report
  alias Stoned.Backoffice.Report.DataFlow

  @user_salt Application.fetch_env!(:stoned, :user_salt)

  action_fallback StonedWeb.Fallback

  def create(conn, %{"params" => params}) do
    with {:ok, user} <- UserModel.create(params) do
      conn
      |> put_status(:created)
      |> render("user.json", %{user: user})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- UserModel.get_by_email(email),
         true <- user.active,
         true <- Bcrypt.verify_pass(password, user.password_hash) do
      token = Phoenix.Token.sign(StonedWeb.Endpoint, @user_salt, %{user_id: user.id})

      conn
      |> put_status(:ok)
      |> render("login.json", %{user: user, token: token})
    else
      _ -> {:error, :invalid_credentials}
    end
  end

  def deposit(conn, %{"params" => %{"value" => value}}) when value > 0 do
    user = conn.private.auth.user

    with {:ok, pid} <- AccountAPI.start(user.email),
         {:ok, state} <- AccountAPI.deposit(pid, value) do
      conn
      |> put_status(:ok)
      |> put_resp_content_type("application/json")
      |> render("user.json", %{user: state})
    else
      _ -> {:error, :transfer}
    end
  end

  def withdraw(conn, %{"params" => %{"value" => value}}) when value > 0 do
    user = conn.private.auth.user

    with {:ok, pid} <- AccountAPI.start(user.email),
         {:ok, state} <- AccountAPI.withdraw(pid, value) do
      conn
      |> put_status(:ok)
      |> put_resp_content_type("application/json")
      |> render("user.json", %{user: state})
    else
      _ -> {:error, :transfer}
    end
  end

  def transfer(conn, %{"params" => %{"value" => value, "receiver" => receiver}}) when value > 0 do
    user = conn.private.auth.user

    with {:ok, pid} <- AccountAPI.start(user.email),
         {:ok, state} <- AccountAPI.transfer(pid, %{value: value, to: receiver}) do
      conn
      |> put_status(:ok)
      |> put_resp_content_type("application/json")
      |> render("user.json", %{user: state})
    else
      _ -> {:error, :transfer}
    end
  end

  def backoffice_report(conn, %{"params" => %{"start_date" => _start} = params}) do
    with {:ok, report_req} <- Report.changeset(%Report{}, params) do
      payload = Enum.into(DataFlow.start_flow(report_req.start_date), %{})
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{data: payload}))
    else
      _ -> {:error, :invalid_params}
    end
  end
end
