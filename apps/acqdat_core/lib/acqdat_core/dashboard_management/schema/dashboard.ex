defmodule AcqdatCore.DashboardManagement.Schema.Dashboard do
  @moduledoc """
  Models a Dashboard Entity.

  Dashboard are used for visually representing collection of widgets to user.

  Any particular project can have multiple dashboards.

  A dashboard consists of multiple widgets.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance

  @typedoc """
  `name`: Name of the dashboard, which will be unique with respective to project.
  `uuid`: A universally unique id to identify the Dashboard.
  `settings`: All the settings of dashboard
  """
  @type t :: %__MODULE__{}
  schema("acqdat_dashboard") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:settings, :map)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:project, Project, on_replace: :delete)
    has_many(:widget_instances, WidgetInstance)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid slug name org_id project_id)a
  @optional_params ~w(settings description)a
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
    |> assoc_constraint(:org)
    |> assoc_constraint(:project)
    |> unique_constraint(:name,
      name: :unique_dashboard_name_per_project,
      message: "unique name under project"
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
