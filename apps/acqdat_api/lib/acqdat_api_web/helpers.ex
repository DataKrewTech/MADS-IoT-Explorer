defmodule AcqdatApiWeb.Helpers do
	@moduledoc """
  Generic helper functions for API application.
  """

  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [render: 3, put_view: 2]

  def extract_changeset_data(changeset) do
    if changeset.valid?() do
      {:ok, Params.data(changeset)}
    else
      {:error, extract_changeset_error(changeset)}
    end
  end

  def extract_changeset_error(changeset) do
		Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
			Enum.reduce(opts, msg, fn {key, value}, acc ->
					String.replace(acc, "%{#{key}}", to_string(value))
			end)
    end)
  end

  def send_error(conn, code, message) when is_binary(message) do
    conn |> prepare_send_error(code) |> render("#{code}.json", %{errors: message})
  end

  def send_error(conn, code, message) do
    conn |> prepare_send_error(code) |> render("#{code}.json", %{errors: message})
  end

  defp prepare_send_error(conn, code) do
    conn
    |> put_status(code)
    |> put_view(AcqdatApiWeb.ErrorView)
  end
end
