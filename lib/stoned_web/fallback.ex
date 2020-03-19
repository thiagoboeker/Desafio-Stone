defmodule StonedWeb.Fallback do
  @moduledoc false
  use StonedWeb, :controller

  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      401,
      Jason.encode!(%{
        errors: %{
          auth: "INVALID CREDENTIALS"
        }
      })
    )
  end

  def call(conn, {:error, :transfer}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      400,
      Jason.encode!(%{
        errors: %{
          transfer: "TRANSFERENCE ERROR"
        }
      })
    )
  end

  def call(conn, {:error, :invalid_params}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      400,
      Jason.encode!(%{
        errors:  %{
          parameters: "INVALID PARAMETERS"
        }
      })
    )
  end

  def call(conn, {:error, error}) when is_binary(error) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      400,
      Jason.encode!(%{
        errors: %{
          operation: error
        }
      })
    )
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(StonedWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, %Ecto.Changeset{} = changeset) do
    call(conn, {:error, changeset})
  end
end
