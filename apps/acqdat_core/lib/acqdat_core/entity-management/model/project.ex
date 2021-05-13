defmodule AcqdatCore.Model.EntityManagement.Project do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Project.changeset(%Project{}, params)
    Repo.insert(changeset)
  end

  def return_count(_params) do
    query =
      from(p in Project,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def hierarchy_data(org_id, project_id) do
    org_projects = fetch_projects(org_id, project_id)

    Enum.reduce(org_projects, [], fn project, acc ->
      entities = AssetModel.child_assets(project.id)
      sensors = SensorModel.get_all_by_parent_project(project.id)
      map_data = Map.put_new(project, :assets, entities)
      acc ++ [Map.put_new(map_data, :sensors, sensors)]
    end)
  end

  def hierarchy_data_for_gateway(org_id, project_id) do
    org_projects = fetch_projects(org_id, project_id)

    Enum.reduce(org_projects, [], fn project, acc ->
      entities = AssetModel.child_assets_including_gateway(project.id)
      sensors = SensorModel.get_all_by_parent_project(project.id)
      map_data = Map.put_new(project, :assets, entities)
      acc ++ [Map.put_new(map_data, :sensors, sensors)]
    end)
  end

  def gen_topology(org_id, %{name: name, id: project_id, uuid: project_uuid}) do
    proj_hierarchy = hierarchy_data(org_id, project_id) |> cumulate_assets_n_sensors()

    %{id: "#{project_uuid}", name: name, type: "Project", children: proj_hierarchy}
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Project, id) do
      nil ->
        {:error, "not found"}

      project ->
        {:ok, project}
    end
  end

  def get_for_view(project_ids) do
    query =
      from(project in Project,
        where: project.id in ^project_ids,
        preload: [:leads, :users, :creator],
        order_by: [desc: :inserted_at]
      )

    Repo.all(query)
  end

  def update_version(%Project{} = project) do
    changeset = Project.update_changeset(project, %{version: Decimal.add(project.version, "0.1")})
    Repo.update(changeset)
  end

  # NOTE: Version of Project will be incremented, whenever any update on Project happens
  def update(%Project{} = project, params) do
    changeset = Project.update_changeset(project, params)

    changeset =
      if changeset.changes != %{} do
        params = params |> Map.put_new("version", Decimal.add(project.version, "0.1"))
        Project.update_changeset(project, params)
      else
        changeset
      end

    Repo.update(changeset)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Project |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}, preloads) do
    query =
      from(project in Project,
        where: project.org_id == ^org_id and project.archived == false
      )

    paginated_project_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    project_data_with_preloads = paginated_project_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(project_data_with_preloads, paginated_project_data)
  end

  def get_all_archived(
        %{page_size: page_size, page_number: page_number, org_id: org_id},
        preloads
      ) do
    query =
      from(project in Project,
        where: project.org_id == ^org_id and project.archived == true
      )

    paginated_project_data =
      query
      |> order_by(desc: :inserted_at)
      |> Repo.paginate(page: page_number, page_size: page_size)

    project_data_with_preloads = paginated_project_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(project_data_with_preloads, paginated_project_data)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Project, id) do
      nil ->
        {:error, "Project not found"}

      project ->
        {:ok, project}
    end
  end

  def get(params) when is_map(params) do
    case Repo.get_by(Project, params) do
      nil ->
        {:error, "Project not found"}

      project ->
        {:ok, project}
    end
  end

  def check_adminship(user_id) do
    user_details = Repo.get!(User, user_id) |> Repo.preload([:role])

    case user_details.role.name == "admin" do
      true -> true
      false -> false
    end
  end

  def delete(project) do
    changeset = Project.delete_changeset(project)

    case Repo.delete(changeset) do
      {:ok, project} ->
        project = project |> Repo.preload([:leads, :users])
        {:ok, project}

      {:error, project} ->
        {:error, project}
    end
  end

  ################# private functions ###############

  defp fetch_projects(org_id, project_id) do
    query =
      from(project in Project,
        where: project.org_id == ^org_id and project.id == ^project_id
      )

    Repo.all(query)
  end

  defp cumulate_assets_n_sensors(hire_data) do
    Enum.reduce(hire_data, [], fn project, acc ->
      assets = if Map.has_key?(project, :assets), do: group_by_asset_type(project), else: []
      sensors = if Map.has_key?(project, :sensors), do: group_by_senor_type(project), else: []
      acc ++ assets ++ sensors
    end)
  end

  defp group_by_senor_type(entity) do
    grouped_data = Enum.group_by(entity.sensors, fn x -> x.sensor_type end, fn y -> y.name end)

    Enum.reduce(grouped_data, [], fn {key, val}, acc ->
      acc ++ [%{id: "#{key.id}_#{key.name}", name: key.name, type: "SensorType"}]
    end)
  end

  defp group_by_asset_type(entity) do
    grouped_data =
      Enum.group_by(entity.assets, fn x -> x.asset_type end, fn asset ->
        assets =
          if Map.has_key?(asset, :assets) do
            group_by_asset_type(asset)
          end

        sensors =
          if Map.has_key?(asset, :sensors) do
            group_by_senor_type(asset)
          end

        formulate_assets_n_sensors(assets, sensors)
      end)

    grouped_data |> cumulate_assets_data()
  end

  defp formulate_assets_n_sensors(assets, sensors) do
    case {assets, sensors} do
      {nil, sensors} ->
        sensors

      {assets, nil} ->
        {key, value} = Enum.at(assets, 0)

        %{
          id: "#{key.id}_#{key.name}",
          name: key.name,
          type: "AssetType",
          children: Enum.uniq(List.flatten(value))
        }

      {assets, sensors} ->
        [assets] ++ sensors
    end
  end

  defp cumulate_assets_data(data) do
    Enum.reduce(data, [], fn {key, val}, acc ->
      acc ++
        [
          %{
            id: "#{key.id}_#{key.name}",
            name: key.name,
            type: "AssetType",
            children: Enum.uniq(List.flatten(val))
          }
        ]
    end)
  end
end
