defmodule AcqdatCore.Seed.EntityManagement.Asset do
  alias AcqdatCore.Schema.EntityManagement.{Asset, Organisation, Project}
  import AsNestedSet.Modifiable
  alias AcqdatCore.Repo
  import Tirexs.HTTP

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
    for asset <- @asset_manifest do
      create_taxonomy(asset)
    end
  end

  def create_taxonomy({parent, children, properties}) do
    [org] = Repo.all(Organisation)
    [project | _] = Repo.all(Project)

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
          properties: properties
          },
        :org
      )

     root = add_root(asset)
     insert_asset("assets", root)
     for taxon <- children do
       create_taxon(taxon, root)
     end
  end

  def add_root(%Asset{} = root) do
    root
    |> create(:root)
    |> AsNestedSet.execute(Repo)
  end

  defp create_taxon({parent, children, properties}, root) do
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
          properties: properties
          },
          [:org])

    {:ok, root} = add_taxon(root, child, :child)

    for taxon <- children do
      create_taxon(taxon, root)
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
      uuid: params.uuid
      )
  end
end

