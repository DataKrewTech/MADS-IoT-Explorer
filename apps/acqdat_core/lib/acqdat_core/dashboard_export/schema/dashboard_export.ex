defmodule AcqdatCore.DashboardExport.Schema.DashboardExport do
  @moduledoc """
  Dashboard export is the feature which enables a user to export any valid dashboard

  This can be achieved in 2 way
  - `public`
  - `private`

  ***public***
  publicly exported dashboard is visible to everyone who holds that url which consist of dashboard uuid and token generate by us

  ***private***
  privately exported dashboard is the one which is visible to only those which hold the user_id and password created and shared by
  the user who is exporting it.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.DashboardManagement.Schema.Dashboard

  @typedoc """
  `dashboard_uuid`: dashboard uuid
  `token`: jwt for exported dashboard to login
  `is_secure`: true in case of privately exported dashboard else false
  `password`: in case the user export dashboard privately
  """

  @type t :: %__MODULE__{}

  schema("acqdat_dashboard_export") do
    field(:token, :string)
    field(:url, :string)
    field(:dashboard_uuid, :string, null: false)
    field(:is_secure, :boolean, null: false, default: false)
    field(:password, :string)
    belongs_to(:dashboard, Dashboard)
    timestamps(type: :utc_datetime)
  end

  @required ~w(token dashboard_uuid dashboard_id url is_secure)a
  @optional ~w(password)a
  @permitted @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = dashboard_export, params) do
    dashboard_export
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:dashboard_uuid,
      name: :restrict_already_exported_dashboard,
      message: "Dashboard has already been exported previously."
    )
  end
end
