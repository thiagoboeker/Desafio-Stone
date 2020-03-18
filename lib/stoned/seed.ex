defmodule Stoned.Seeds do
  @moduledoc false

  def run() do
    {:ok, _} = Application.ensure_all_started(:stoned)
    param = %{name: "user_admin", role: "ADMIN", email: "stoned_admin@gmail", password: "admin@stoned"}
    Stoned.DB.UserModel.create(param)
  end
end
