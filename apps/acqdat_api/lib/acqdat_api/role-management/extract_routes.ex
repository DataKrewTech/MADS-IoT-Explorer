defmodule AcqdatApi.RoleManagement.ExtractRoutes do
  alias AcqdatApiWeb.Router

  # route struct sample
  # %Phoenix.Router.Route{
  #   assigns: %{},
  #   helper: "dashboard_export",
  #   host: nil,
  #   kind: :match,
  #   line: 28,
  #   metadata: %{log: :debug},
  #   path: "/dashboards/:dashboard_uuid",
  #   pipe_through: [:export_auth],
  #   plug: AcqdatApiWeb.DashboardExport.DashboardExportController,
  #   plug_opts: :export,
  #   private: %{},
  #   trailing_slash?: false,
  #   verb: :get
  # }
  def extract() do
    routes = Router.__routes__()

    Enum.reduce(routes, %{}, fn route, acc ->
      extract_information(route, acc)
    end)
  end

  defp extract_information(
         %{plug: controller_name, verb: request_type, plug_opts: path_name},
         acc
       ) do
    [controller, action] =
      controller_name |> to_string |> String.split(".") |> return_controller_and_action()

    case Map.has_key?(acc, controller) do
      false ->
        value = Map.new() |> Map.put_new(action, [%{request_type: request_type, path: path_name}])
        Map.put_new(acc, controller, value)

      true ->
        actions = Map.fetch!(acc, controller)

        actions =
          case Map.has_key?(actions, action) do
            true ->
              temp_value = Map.fetch!(actions, action)
              value = temp_value ++ [%{request_type: request_type, path: path_name}]
              Map.replace!(actions, action, value)

            false ->
              value = [%{request_type: request_type, path: path_name}]
              Map.put_new(actions, action, value)
          end

        Map.replace!(acc, controller, actions)
    end
  end

  defp return_controller_and_action([_, controller, action]) do
    [controller, action]
  end

  defp return_controller_and_action([_, _, controller, action]) do
    [controller, action]
  end
end
