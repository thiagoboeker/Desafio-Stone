defmodule StonedWeb.UserView do
  @moduledoc false
  use StonedWeb, :view

  def render("user.json", %{user: user}) do
    %{
      data: %{
        id: user.id,
        email: user.email,
        credit: user.credit,
        active: user.active
      }
    }
  end

  def render("login.json", %{user: user, token: token}) do
    "user.json"
    |> render(%{user: user})
    |> Map.put(:token, token)
  end
end
