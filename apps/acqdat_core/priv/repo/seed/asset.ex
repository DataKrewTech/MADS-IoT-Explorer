defmodule AcqdatCore.Seed.Asset do
  
  alias AcqdatCore.Schema.{Asset, Organisation}
  import AsNestedSet.Modifiable
  alias AcqdatCore.Repo
  
  @asset_manifest [
    {
    "Bintan Factory",
      [
        {"Wet Process", []},
        {"Dry Process", []}
      ]
    },
    {
      "Singapore Office",
      [
        {"Common Space", []},
        {"Executive Space", []}
      ]
    },
    { "Ipoh Factory", []}
  ]

  def seed_asset!() do
    for asset <- @asset_manifest do
      create_taxonomy(asset)
    end
  end

  def create_taxonomy({parent, children}) do
    [org] = Repo.all(Organisation)
    asset =
      Repo.preload(
        %Asset{
          name: parent, 
          org_id: org.id, 
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second), 
          updated_at: DateTime.truncate(DateTime.utc_now(), :second),
          uuid: UUID.uuid1(:hex),
          slug: Slugger.slugify(org.name <> parent)
          },
        :org
      )

     root = add_root(asset)

     for taxon <- children do
       create_taxon(taxon, root)
     end
  end

  def add_root(%Asset{} = root) do
    root
    |> create(:root)
    |> AsNestedSet.execute(Repo)
  end

  defp create_taxon({parent, children}, root) do

    child =
      Repo.preload(
        %Asset{
          name: parent, 
          org_id: root.org.id, 
          parent_id: root.id,
          uuid: UUID.uuid1(:hex), 
          slug: Slugger.slugify(root.org.name <> root.name <> parent), 
          inserted_at: DateTime.truncate(DateTime.utc_now(), :second), 
          updated_at: DateTime.truncate(DateTime.utc_now(), :second)
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
        |> create(parent, position)
        |> AsNestedSet.execute(Repo)

      {:ok, taxon}
    rescue
      error in Ecto.InvalidChangesetError ->
        {:error, error.changeset}
    end
  end
end