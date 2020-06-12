defmodule AcqdatCore.Seed.EntityManagement.Asset do
  import AsNestedSet.Modifiable
  import Tirexs.HTTP
  alias AcqdatCore.Schema.EntityManagement.{Asset, Organisation, Project, AssetType}
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo

  @asset_manifest [
    {
    "Bintan Factory",
      [
        {"Wet Process",[], ["voltage", "current", "power", "x_axis_vel", "z_axis_vel", "x_axis_acc"]},
        {"Dry Process", [], ["temperature"]}
      ],
      []
    },
    {
      "Singapore Office",
      [
        {"Common Space", [], ["occupancy"]},
        {"Executive Space", [], ["occupancy"]}
      ],
      ["voltage", "current", "power"]
    },
    { "Ipoh Factory", [], ["air_temperature", "o2_level", "co2_level", "co_level", "soil_humidity", "n_level", "p_level"]}
  ]

  def seed_asset!() do
    [org] = Repo.all(Organisation)
    [project | _] = Repo.all(Project)
    asset_type = seed_asset_type(org, project)
    for asset <- @asset_manifest do
      create_taxonomy(asset, asset_type, org, project)
    end
  end

  def create_taxonomy({parent, children, properties}, asset_type, org, project) do
    [user] = Repo.all(User)

    asset =
      Repo.preload(
        %Asset{
          name: parent,
          org_id: org.id,
          project_id: project.id,
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
          updated_at: DateTime.truncate(DateTime.utc_now(), :second),
          uuid: UUID.uuid1(:hex),
          slug: Slugger.slugify(org.name <>parent),
          properties: properties,
          asset_type_id: asset_type.id,
          creator_id: user.id
          },
        :org
      )

      root = add_root(asset)
     insert_asset("assets", root)
     for taxon <- children do
       create_taxon(taxon, root, asset_type, user)
     end
  end

  def add_root(%Asset{} = root) do
    root
    |> create(:root)
    |> AsNestedSet.execute(Repo)
  end

  defp create_taxon({parent, children, properties}, root, asset_type, user) do
    child =
      Repo.preload(
        %Asset{
          name: parent,
          org_id: root.org.id,
          project_id: root.project_id,
          parent_id: root.id,
          uuid: UUID.uuid1(:hex),
          slug: Slugger.slugify(root.org.name <> root.name <> parent),
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
          updated_at: DateTime.truncate(DateTime.utc_now(), :second),
          properties: properties,
          asset_type_id: asset_type.id,
          creator_id: user.id
          },
          [:org])
    {:ok, root} = add_taxon(root, child, :child)
    for taxon <- children do
      create_taxon(taxon, root, asset_type, user)
    end
  end

  def add_taxon(%Asset{} = parent, %Asset{} = child, position) do
    try do
      taxon =
        %Asset{child | org_id: parent.org.id}
        |> Repo.preload(:org)
        |> Repo.preload(:project)
        |> create(parent, position)
        |> AsNestedSet.execute(Repo)
      insert_asset("assets", taxon)
      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end

  def insert_asset(type, params) do
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      name: params.name,
      properties: params.properties,
      slug: params.slug,
      uuid: params.uuid,
      project_id: params.project_id
      )
  end

  defp seed_asset_type(org, project) do
    asset_type = %AssetType{
        name: "Asset Type",
        description: "This is seeded asset type",
        sensor_type_present: false,
        uuid: UUID.uuid1(:hex),
        slug: Slugger.slugify("Asset Type"),
        org_id: org.id,
        project_id: project.id
     }
     case Repo.insert(asset_type) do
       {:ok, asset_type} -> asset_type
       {:error, error} -> raise RuntimeError, message: "Problem Inserting Asset Type"
     end
  end
end
