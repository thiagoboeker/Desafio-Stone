defmodule StonedWeb.ChangesetView do
  @moduledoc false
  use StonedWeb, :view

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    %{data: %{errors: translate_errors(changeset)}}
  end
end
