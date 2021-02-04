defmodule AcqdatApiWeb.ErrorView do
  use AcqdatApiWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("200.json", assigns) do
    handle_assign_error("", assigns)
  end

  def render("401.json", assigns) do
    :unauthenticated |> err() |> handle_assign_error(assigns)
  end

  def render("403.json", assigns) do
    :unauthorized |> err() |> handle_assign_error(assigns)
  end

  def render("400.json", assigns) do
    :bad_request |> err() |> handle_assign_error(assigns)
  end

  def render("404.json", assigns) do
    :not_found |> err() |> handle_assign_error(assigns)
  end

  def render("500.json", assigns) do
    err(:server_error) |> handle_assign_error(assigns)
  end

  defp handle_assign_error(default_message, assigns) do
    case has_assign_error_key?(assigns) do
      {:ok, errors} ->
        %{
          status_code: assigns.conn.status,
          title: errors.title,
          detail: errors.error,
          source: errors.source
        }

      _ ->
        %{
          status_code: assigns.conn.status,
          title: default_message,
          source: nil,
          detail: "You are not allowed to perform this action."
        }
    end
  end

  defp has_assign_error_key?(assigns) do
    if Map.has_key?(assigns, :errors) do
      {:ok, parse_errors(assigns.errors)}
    else
      nil
    end
  end

  defp parse_errors(args) when is_map(args) do
    if Map.has_key?(args, :__struct__) do
      Map.from_struct(args)
    else
      args
    end
  end

  defp parse_errors(args), do: args

  defp err(message) do
    case message do
      :server_error -> "Server Error"
      :not_found -> "Not Found"
      :unknown_resource_type -> "Unknown resource type"
      :unauthenticated -> "Unauthenticated"
      :unauthorized -> "Unauthorized"
      :unexpected_state -> "unexpected_state"
      :bad_request -> "Bad Request"
    end
  end
end
