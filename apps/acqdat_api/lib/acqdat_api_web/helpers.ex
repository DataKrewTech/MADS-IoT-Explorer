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
    error =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    %{
      title: "Insufficient or not unique parameters",
      error:
        "Parameters provided to perform current action either not valid or missing or not unique",
      source: ectract_error(error)
    }
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

  defp ectract_error(error) do
    Enum.reduce(error, %{}, fn {key, value}, acc ->
      Map.merge(acc, %{"#{key}": reduce_error(value)})
    end)
  end

  defp remove_empty_maps(value) do
    Enum.reduce(value, [], fn v, acc ->
      case List.first(Map.keys(v)) do
        nil -> acc
        _ -> acc ++ [v]
      end
    end)
  end

  defp reduce_error(value) when is_list(value) do
    case length(value) do
      1 ->
        value

      _ ->
        value = remove_empty_maps(value)

        for v <- value do
          reduce_error(v)
        end
    end
  end

  defp reduce_error(value) when is_binary(value) do
    value
  end

  defp reduce_error(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, v}, acc ->
      Map.merge(acc, %{"#{key}": List.to_string(v)})
    end)
  end
end
