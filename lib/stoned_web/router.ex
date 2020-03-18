defmodule StonedWeb.Router do
  @moduledoc false
  use StonedWeb, :router

  import StonedWeb.AuthController

  pipeline :api do
    plug :accepts, ["json"]
    plug :user_auth, role: "USER"
  end

  pipeline :admin do
    plug :accepts, ["json"]
    plug :user_auth, role: "ADMIN"
  end

  scope "/api", StonedWeb do
    post "/user", UserController, :create
    post "/login", UserController, :login

    scope "/backoffice" do
      pipe_through :admin
      post "/", UserController, :backoffice_report
    end

    pipe_through :api
    post "/deposit", UserController, :deposit
    post "/withdraw", UserController, :withdraw
    post "/transfer", UserController, :transfer
  end
end
