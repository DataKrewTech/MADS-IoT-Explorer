defmodule AcqdatCore.Schema.RoleManagement.ForgotPassword do
  @moduledoc """
  Models a table which contains details related to user and their respective token which will be accessed at the time of resetting password
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{User}

  @type t :: %__MODULE__{}

  schema "acqdat_recovery_details" do
    # associations
    field(:token, :string, null: false)
    belongs_to(:user, User)
    timestamps(type: :utc_datetime)
  end

  @required_params ~w(user_id token)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = forgot_password, params) do
    common_changeset(forgot_password, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = forgot_password, params) do
    common_changeset(forgot_password, params)
  end

  defp common_changeset(forgot_password, params) do
    forgot_password
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:token, name: :unique_token_per_user)
  end
end
