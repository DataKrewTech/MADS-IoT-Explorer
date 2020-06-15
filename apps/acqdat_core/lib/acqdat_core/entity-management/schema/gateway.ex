defmodule AcqdatCore.Schema.EntityManagement.Gateway do
  @moduledoc """
  Models a Gateway in the system.

  A Gateway can be any entity which receives data from sensor and send data
  to and forth in our given platform.
  """
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}

  @typedoc """
  `uuid`: A universally unique id to identify the gateway.
  `name`: Name for easy identification of the gateway.
  `access_token`: Access token to be used while sending data
              to server from the gateway.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_gateway") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string)
    field(:parent_type, :string)
    field(:parent_id, :integer)
    field(:description, :string)
    field(:access_token, :string, null: false)
    field(:serializer, :map)

    field(:current_location, :map)
    field(:channel, :string, null: false)
    field(:status, :integer, virtual: true)
    field(:image_url, :string)
    field(:image, :any, virtual: true)
    field(:static_data, {:array, :map})
    field(:streaming_data, {:array, :map})
    field(:mapped_parameters, :map)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:project, Project, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name access_token slug uuid org_id project_id channel parent_id parent_type)a
  @optional_params ~w(description serializer current_location image_url static_data streaming_data mapped_parameters)a

  @permitted @required_params ++ @optional_params

  def changeset(%__MODULE__{} = gateway, params) do
    gateway
    |> cast(params, @permitted)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = gateway, params) do
    gateway
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:project)
    |> unique_constraint(:slug, name: :acqdat_gateway_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_gateway_uuid_index)
    |> unique_constraint(:access_token, name: :acqdat_gateway_access_token_index)
    |> unique_constraint(:name, name: :acqdat_gateway_name_org_id_project_id_index)
  end

  defp add_uuid(changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_slug(changeset) do
    changeset
    |> put_change(:slug, Slugger.slugify(random_string(12)))
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
