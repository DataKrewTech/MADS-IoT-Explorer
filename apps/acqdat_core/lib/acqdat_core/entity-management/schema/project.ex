defmodule AcqdatCore.Schema.EntityManagement.Project do
  @moduledoc """
  Models a Project in the system.
  """
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.RoleManagement.User

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
    field(:metadata, :map)
    field(:location, :map)
    field(:archived, :boolean, default: false)
    field(:version, :integer, default: 1)
    field(:start_date, :utc_datetime)

    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:creator, User, on_replace: :raise)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name uuid slug version creator_id org_id)a
  @optional_params ~w(metadata description location avatar archived start_date)a

  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = project, params) do
    project
    |> cast(params, @permitted)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = project, params) do
    project
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:creator)
    |> unique_constraint(:slug, name: :acqdat_projects_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_projects_uuid_index)
    |> unique_constraint(:version, name: :acqdat_projects_version_index)
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
end
