defmodule AcqdatCore.Schema.EntityManagement.Project do
  @moduledoc """
  Models a Project in the system.
  """
  import Ecto.Query
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Repo

  @typedoc """
  `uuid`: A universally unique id to identify the Project.
  `name`: Name for easy identification of the Project.
  `creator`: Id of creator.
  `org`: Organisation to which this project belongs to
  """
  @type t :: %__MODULE__{}

  schema("acqdat_projects") do
    field(:name, :string, null: false)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:description, :string)
    field(:avatar, :string)
    field(:location, :map)
    field(:archived, :boolean, default: false)
    field(:version, :decimal, precision: 2, scale: 1, default: 1.0)
    field(:start_date, :utc_datetime)

    embeds_many :metadata, Metadata, on_replace: :delete do
      field(:name, :string, null: false)
      field(:data_type, :string, null: false)
      field(:uuid, :string, null: false)
      field(:unit, :string)
      field(:value, :string)
    end

    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:creator, User, on_replace: :raise)
    many_to_many(:leads, User, join_through: "acqdat_project_leads", on_replace: :delete)
    many_to_many(:users, User, join_through: "acqdat_project_users", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name uuid slug version creator_id org_id)a
  @optional_params ~w(description location avatar archived start_date)a
  @embedded_metadata_required ~w(name uuid data_type)a
  @embedded_metadata_optional ~w(unit value)a
  @permitted_metadata @embedded_metadata_optional ++ @embedded_metadata_required

  @permitted @required_params ++ @optional_params

  def changeset(%__MODULE__{} = project, params) do
    project
    |> cast(params, @permitted)
    |> cast_embed(:metadata, with: &metadata_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
    |> put_project_leads(params.lead_ids)
    |> put_project_users(params.user_ids)
  end

  def update_changeset(%__MODULE__{} = project, params) do
    project
    |> cast(params, @permitted)
    |> cast_embed(:metadata, with: &metadata_changeset/2)
    |> validate_required(@required_params)
    |> common_changeset()
    |> put_project_leads(params["lead_ids"])
    |> put_project_users(params["user_ids"])
  end

  def delete_changeset(%__MODULE__{} = project) do
    project
    |> cast(%{}, [])
    |> foreign_key_constraint(:asset_types,
      name: :acqdat_asset_types_project_id_fkey,
      message: "asset_types are attached to this project"
    )
    |> foreign_key_constraint(:sensor_types,
      name: :acqdat_sensor_types_project_id_fkey,
      message: "sensor_types are attached to this project"
    )
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:creator)
    |> unique_constraint(:slug, name: :acqdat_projects_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_projects_uuid_index)
    |> unique_constraint(:name,
      name: :unique_project_per_org,
      message: "unique name under organisation"
    )
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_slug(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:slug, Slugger.slugify(random_string(12)))
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp put_project_users(changeset, user_ids) do
    case is_nil(user_ids) do
      false ->
        users = Repo.all(from(user in User, where: user.id in ^user_ids))
        put_assoc(changeset, :users, Enum.map(users, &change/1))

      true ->
        changeset
    end
  end

  defp put_project_leads(changeset, lead_ids) do
    case is_nil(lead_ids) do
      false ->
        leads = Repo.all(from(user in User, where: user.id in ^lead_ids))
        put_assoc(changeset, :leads, Enum.map(leads, &change/1))

      true ->
        changeset
    end
  end

  defp metadata_changeset(schema, params) do
    schema
    |> cast(params, @permitted_metadata)
    |> add_uuid()
    |> validate_required(@embedded_metadata_required)
  end
end
