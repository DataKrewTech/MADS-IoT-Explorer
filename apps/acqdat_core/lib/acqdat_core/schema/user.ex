defmodule AcqdatCore.Schema.User do
  @moduledoc """
  Models a user in acqdat.
  """

  use AcqdatCore.Schema
  alias Comeonin.Argon2
  alias AcqdatCore.Schema.{UserSetting, Organisation}
  alias AcqdatCore.Schema.Role

  @password_min_length 8
  @type t :: %__MODULE__{}

  schema("users") do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:is_invited, :boolean, default: false)
    field(:password_hash, :string)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    has_one(:user_setting, UserSetting)
    belongs_to(:role, Role)

    timestamps(type: :utc_datetime)
  end

  @required ~w(first_name email password is_invited password_confirmation role_id)a
  @optional ~w(password_hash last_name)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common_changeset
  end

  def update_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @permitted)
    |> common_changeset
  end

  def common_changeset(changeset) do
    changeset
    |> unique_constraint(:email, name: :unique_email)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: @password_min_length)
    |> validate_format(:email, ~r/@/)
    |> put_pass_hash()
    |> assoc_constraint(:org)
    |> assoc_constraint(:role)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true} = changeset) do
    case fetch_change(changeset, :password) do
      {:ok, password} ->
        changeset
        |> change(Argon2.add_hash(password))
        |> delete_change(:password_confirmation)

      :error ->
        changeset
    end
  end

  defp put_pass_hash(changeset), do: changeset
end
