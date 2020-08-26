defmodule AcqdatCore.DashboardManagement.Schema.CommandWidget do
  @moduledoc """
  Models a command widget.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.DashboardManagement.Schema.Panel

  @callback handle_command(data_setting_parameters :: map) ::
              {:ok, String.t()} | {:error, String.t()}

  @callback widget_parameters() :: map
  @callback widget_type() :: String.t()
  @callback widget_name() :: String.t()
  @callback image_url() :: String.t()

  @type t :: %__MODULE__{}

  schema("acqdat_command_widgets") do
    field(:label, :string, null: false)
    field(:properties, :map)
    field(:uuid, :string)
    field(:module, CommandWidgetSchemaEnum)
    field(:visual_settings, :map)
    field(:data_settings, :map)
    field(:command_widget_type, :string)

    # associations
    belongs_to(:gateway, Gateway, on_replace: :delete)
    belongs_to(:panel, Panel, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(label module gateway_id panel_id)a
  @optional ~w(properties uuid data_settings
    visual_settings command_widget_type)a
  @permitted @required ++ @optional

  def changeset(%__MODULE__{} = command_widget, params) do
    command_widget
    |> cast(params, @permitted)
    |> add_uuid()
    |> validate_required(@required)
    |> add_command_widget_type()
    |> assoc_constraint(:gateway)
    |> assoc_constraint(:panel)
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_command_widget_type(%Ecto.Changeset{valid?: true} = changeset) do
    module = get_field(changeset, :module)
    widget_type = module.widget_type

    changeset
    |> put_change(:command_widget_type, widget_type)
  end

  defp add_command_widget_type(changeset), do: changeset
end
