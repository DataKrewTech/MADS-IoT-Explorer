defmodule AcqdatCore.Schema.RoleManagement.UserCredentials do
  @moduledoc """
  Models a user credentials in acqdat.
  """
  use AcqdatCore.Schema
  alias Comeonin.Argon2
  alias AcqdatCore.Schema.RoleManagement.User

  @password_min_length 8
  @type t :: %__MODULE__{}

  schema("acqdat_user_credentials") do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:phone_number, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    # associations
    has_many(:user, User)

    timestamps(type: :utc_datetime)
  end

  @required ~w(first_name email)a
  # need to change and move password and password confirmation to
  @optional ~w(phone_number password password_confirmation last_name password_hash)a
  # required field once the migration is done
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = user_cred, params) do
    user_cred
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common_changeset(params)
  end

  def common_changeset(changeset, _params) do
    changeset
    |> unique_constraint(:email, name: :acqdat_user_credentials_email_index)
    |> validate_format(:email, ~r/@/)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: @password_min_length)
    |> put_pass_hash()
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
