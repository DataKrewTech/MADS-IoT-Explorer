defmodule AcqdatCore.DashboardManagement.Schema.Dashboard do
  @moduledoc """
  Models a Dashboard Entity.

  Dashboard are used for visually representing collection of widgets to user.

  Any particular org can have multiple dashboards.

  A dashboard consists of multiple widgets.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.DashboardManagement.Schema.Panel
  alias AcqdatCore.DashboardExport.Schema.DashboardExport
  alias AcqdatCore.DashboardManagement.Schema.Dashboard.Settings

  @typedoc """
  `name`: Name of the dashboard, which will be unique with respective to org.
  `uuid`: A universally unique id to identify the Dashboard.
  `settings`: All the settings of dashboard
  """
  @type t :: %__MODULE__{}
  schema("acqdat_dashboard") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:avatar, :string)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    has_many(:panels, Panel, on_replace: :delete)

    # embedded associations
    embeds_one(:settings, Settings, on_replace: :delete)
    has_one(:dashboard_export, DashboardExport)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid slug name org_id)a
  @optional_params ~w(description avatar)a
  @permitted @optional_params ++ @required_params

  def changeset(%__MODULE__{} = dashboard, params) do
    dashboard
    |> cast(params, @permitted)
    |> add_slug()
    |> add_uuid()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = dashboard, params) do
    dashboard
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def common_changeset(changeset) do
    changeset
    |> cast_embed(:settings, with: &Settings.changeset/2)
    |> assoc_constraint(:org)
    |> unique_constraint(:name,
      name: :unique_dashboard_name_per_org,
      message: "unique name under org"
    )
  end

  # TODO: Need to remove these codes, after fbp branch is merged to master
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

defmodule AcqdatCore.DashboardManagement.Schema.Dashboard.Settings do
  @moduledoc """
  Embed schema for settings related to dashboard.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:background_color, :string, default: "#FFFFFF")
    field(:sidebar_color, :string, default: "#000000")
    field(:client_name, :string)
  end

  @permitted ~w(background_color sidebar_color client_name)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end
end
