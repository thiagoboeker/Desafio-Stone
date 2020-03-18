defmodule StonedWeb.AuthController do
  @moduledoc """
  Modulo de autenticacao dos usuarios
  """
  alias Stoned.DB.UserModel
  alias StonedWeb.Fallback
  import Plug.Conn

  @user_salt Application.fetch_env!(:stoned, :user_salt)
  @exp 86400

  def get_token(conn = %Plug.Conn{}) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      {:ok, token}
    else
      _ -> {:error, :invalid}
    end
  end

  def user_auth(conn, role: role) do
    with {:ok, token} <- get_token(conn), # Retira a token do header
         {:ok, %{user_id: user_id}} <-
           Phoenix.Token.verify(StonedWeb.Endpoint, @user_salt, token, max_age: @exp), # Recebe o user_id da token
         {:ok, %{role: role} = user} <- UserModel.get(user_id) do
      put_private(conn, :auth, %{user: user})
    else
      _ -> Fallback.call(halt(conn), {:error, :invalid_credentials})
    end
  end
end
