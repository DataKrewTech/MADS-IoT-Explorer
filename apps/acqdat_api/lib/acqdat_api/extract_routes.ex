defmodule AcqdatApi.ExtractRoutes do
  alias AcqdatApiWeb.Router
  alias AcqdatCore.Schema.RoleManagement.Policy
  alias AcqdatCore.Repo
  use Agent

  @neglect_routes ~w(AcqdatApiWeb Bamboo)s

  #   "DashboardManagement" => %{  //This is the application name
  #     "DashboardExport" => {  //This is the feature inside that application`
  #       "controller" => "DashboardExportController",
  #       "actions" => { //These are the actions inside that feature that user is being delegated to.
  #           "export" => %{path: :export, request_type: :get},
  #           "show" => %{path: :show, request_type: :get}
  #       }
  #     }
  #  }

  def start_link(_opts) do
    Agent.start_link(fn -> extract_routes() end, name: __MODULE__)
  end

  def value() do
    Agent.get(__MODULE__, & &1)
  end

  def extract_routes() do
    routes = Router.__routes__()

    routes =
      Enum.reduce(routes, %{}, fn route, acc ->
        create_map(route, acc)
      end)

    routes = Map.drop(routes, @neglect_routes)
    create_policies(routes)
  end

  defp create_map(%{plug: controller_name, verb: request_type, plug_opts: action}, acc) do
    [feature, trunc_controller] =
      controller_name |> to_string |> String.split(".") |> truncate_controller

    case Map.has_key?(acc, feature) do
      true ->
        add_feature_in_existing(acc, [
          feature,
          controller_name,
          trunc_controller,
          request_type,
          action
        ])

      false ->
        add_feature(acc, [feature, controller_name, trunc_controller, request_type, action])
    end
  end

  defp add_feature(acc, [feature, controller_name, trunc_controller, request_type, action]) do
    actions = %{} |> Map.put_new(action, %{path: action, request_type: request_type})

    inside_feature =
      %{} |> Map.put_new(:actions, actions) |> Map.put_new(:controller, controller_name)

    final_struct = %{} |> Map.put_new(trunc_controller, inside_feature)
    Map.put_new(acc, feature, final_struct)
  end

  defp add_feature_in_existing(acc, [
         feature,
         controller_name,
         trunc_controller,
         request_type,
         action
       ]) do
    final_struct = Map.fetch!(acc, feature)

    case Map.has_key?(final_struct, trunc_controller) do
      true ->
        inside_feature = Map.fetch!(final_struct, trunc_controller)
        current_actions = inside_feature.actions

        actions =
          current_actions |> Map.put_new(action, %{path: action, request_type: request_type})

        inside_feature = inside_feature |> Map.replace!(:actions, actions)
        final_struct = final_struct |> Map.replace!(trunc_controller, inside_feature)
        Map.replace!(acc, feature, final_struct)

      false ->
        actions = %{} |> Map.put_new(action, %{path: action, request_type: request_type})

        inside_feature =
          %{} |> Map.put_new(:actions, actions) |> Map.put_new(:controller, controller_name)

        final_struct = final_struct |> Map.put_new(trunc_controller, inside_feature)
        Map.replace!(acc, feature, final_struct)
    end
  end

  defp truncate_controller([_, _, feature, controller_name]) do
    [trunc_controller, _] = controller_name |> String.split("Controller") |> return_trunc
    [feature, trunc_controller]
  end

  defp truncate_controller([_, feature, controller_name]) do
    [trunc_controller, _] = controller_name |> String.split("Controller") |> return_trunc
    [feature, trunc_controller]
  end

  defp return_trunc([trunc_name, _]) do
    [trunc_name, nil]
  end

  defp return_trunc([trunc_name]) do
    [trunc_name, nil]
  end

  defp create_policies(routes) do
    present_routes = convert_to_list(routes)
    present_policies = Repo.all(Policy) |> change_to_map
    policies_to_be_created = present_routes -- present_policies
    Task.start_link(fn -> Repo.insert_all(Policy, policies_to_be_created) end)
    routes
  end

  defp convert_to_list(routes) do
    Enum.reduce(routes, [], fn {app, value}, acc ->
      features = Map.keys(value)
      acc ++ extract_all_actions(app, features, value)
    end)
  end

  defp extract_all_actions(app, features, value) do
    Enum.reduce(features, [], fn feature, acc ->
      %{actions: actions} = value[feature]
      actions = Map.keys(actions)

      action_list =
        Enum.reduce(actions, [], fn action, action_acc ->
          action_acc ++ [%{app: app, feature: feature, action: to_string(action)}]
        end)

      acc ++ action_list
    end)
  end

  defp change_to_map(policies) do
    Enum.reduce(policies, [], fn policy, acc ->
      acc ++ [params_extraction(policy)]
    end)
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__, :inserted_at, :updated_at, :id])
  end
end
