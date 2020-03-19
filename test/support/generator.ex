defmodule Stoned.TestGenerator do
  @moduledoc false
  import Plug.Conn

  def user(email \\ "thiago@gmail") do
    %{
      name: "Usuario",
      email: email,
      password: "123123"
    }
  end

  def put_auth(conn, token) do
    put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
