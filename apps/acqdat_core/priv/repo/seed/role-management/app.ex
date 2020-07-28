defmodule AcqdatCore.Seed.RoleManagement.App do
  alias NimbleCSV.RFC4180, as: CSV
  alias AcqdatCore.Schema.RoleManagement.App
  alias AcqdatCore.Repo

  def seed() do
    Repo.delete_all(App)
    apps_path = Application.app_dir(:acqdat_core, "priv/repo/mads_apps.csv")

    app_list = apps_path
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(fn [name, description, category, vendor, vendor_url, app_store_price, compatibility, copyright, icon_id] ->
      (generate_app_data(name, description, icon_id, category, vendor, vendor_url, app_store_price, compatibility, copyright))
    end)

    Repo.insert_all(App, app_list)
  end

  def generate_app_data(name, description, icon_id, category, vendor, vendor_url, app_store_price, compatibility, copyright) do
    {float_price, _} = Float.parse(app_store_price)
    [
      name: name,
      description: description,
      icon_id: icon_id,
      category: category,
      vendor: vendor,
      vendor_url: vendor_url,
      app_store_price: float_price,
      compatibility: compatibility,
      copyright: copyright,
      uuid: UUID.uuid1(:hex),
      key: generate_app_key(name),
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      updated_at: DateTime.truncate(DateTime.utc_now(), :second)
    ]
  end

  defp generate_app_key(app_name) do
    [ head | tail ] = app_name |> String.split(" ")
    head = head |> String.downcase()
    [head | tail] |> Enum.join("")
  end
end
