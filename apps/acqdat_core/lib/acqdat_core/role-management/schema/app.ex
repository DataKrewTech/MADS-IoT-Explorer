defmodule AcqdatCore.Schema.RoleManagement.App do
  @moduledoc """
  Models a App in the system.
  """
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.Organisation
  alias AcqdatCore.Schema.RoleManagement.User

  @typedoc """
  `name`: Name of the app.
  """
  @type t :: %__MODULE__{}

  # TODO: Need to add more fields as per the future requirements
  schema("acqdat_apps") do
    field(:uuid, :string, null: false)
    field(:name, :string, null: false)
    field(:description, :string)
    field(:avatar, :string)
    field(:icon_id, :string)
    field(:category, :string)
    field(:vendor, :string)
    field(:vendor_url, :string)
    field(:app_store_price, :float)
    field(:app_store_rating, :float)
    field(:in_app_purchases, :boolean)
    field(:in_app_purchases_data, :map)
    field(:compatibility, :string)
    field(:activity_rating, :float)
    field(:copyright, :string)
    field(:license, :string)
    field(:tnc, :string)
    field(:documentation, :string)
    field(:privacy_policy, :string)
    field(:current_version, :float)
    field(:first_date_of_release, :utc_datetime)
    field(:most_recent_date_of_release, :utc_datetime)
    field(:release_history, :map)

    # associations
    many_to_many(:orgs, Organisation,
      join_through: "org_apps",
      join_keys: [app_id: :id, org_id: :id],
      on_replace: :delete
    )

    many_to_many(:users, User, join_through: "app_user")

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid name)a
  @optional_params ~w(description avatar icon_id category vendor vendor_url app_store_price app_store_rating in_app_purchases in_app_purchases_data compatibility activity_rating copyright license tnc documentation privacy_policy current_version first_date_of_release most_recent_date_of_release release_history)a

  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = app, params) do
    app
    |> cast(params, @permitted)
    |> add_uuid()
    |> validate_required(@required_params)
    |> unique_constraint(:name, name: :acqdat_apps_name_index)
    |> unique_constraint(:uuid, name: :acqdat_apps_uuid_index)
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end
end
