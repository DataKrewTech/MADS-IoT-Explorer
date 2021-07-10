defmodule AcqdatCore.Schema.RoleManagement.Requests do
  @moduledoc """
  Models OrgMetrics Requests.
  """

  use AcqdatCore.Schema

  @type t :: %__MODULE__{}

  schema("acqdat_requests") do
    field(:first_name, :string, null: false)
    field(:last_name, :string)
    field(:email, :string, null: false)
    field(:phone_number, :string)
    field(:org_name, :string, null: false)
    field(:org_url, :string, null: false)
    field(:status, :string, default: "pending")
    field(:user_metadata, :map)

    timestamps(type: :utc_datetime)
  end

  @required ~w(first_name last_name email phone_number org_name org_url)a
  @optional ~w(user_metadata status)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = request, params) do
    request
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common_changeset(params)
  end

  def common_changeset(changeset, _params) do
    changeset
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email,
      name: :unique_email_per_org_url,
      message: "email should be unique under org"
    )
  end
end
