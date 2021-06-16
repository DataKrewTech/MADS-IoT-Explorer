defmodule AcqdatCore.Schema.RoleManagement.UserCredentials do
  @moduledoc """
  Models a user credentials in acqdat.
  """
  use AcqdatCore.Schema
  alias Comeonin.Argon2
  alias AcqdatCore.Schema.RoleManagement.{User, UserSetting}
  alias AcqdatCore.Schema.RoleManagement.UserCredentials.Metadata

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
    field(:avatar, :string)

    # associations
    has_one(:user_setting, UserSetting)
    has_many(:user, User)

    # embedded associations
    embeds_one(:metadata, Metadata, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(first_name email)a
  # need to change and move password and password confirmation to
  @optional ~w(phone_number password password_confirmation last_name password_hash avatar)a
  # required field once the migration is done
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = user_cred, params) do
    user_cred
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: @password_min_length)
    |> put_pass_hash()
    |> common_changeset(params)
  end

  def update_changeset(%__MODULE__{} = user_cred, params) do
    user_cred
    |> cast(params, @permitted)
    |> common_changeset(params)
  end

  def common_changeset(changeset, _params) do
    changeset
    |> unique_constraint(:email, name: :acqdat_user_credentials_email_index)
    |> validate_format(:email, ~r/@/)
    |> cast_embed(:metadata, with: &Metadata.changeset/2)
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

defmodule AcqdatCore.Schema.RoleManagement.UserCredentials.Metadata do
  @moduledoc """
  Embed schema for metadata related to Users.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:job_title, :string)
    field(:company, :string)
    field(:company_size, :string)
    field(:industry, :string)
    field(:level, :string)
    field(:state, :string)
    field(:country, :string)
    field(:timezone, :string)
    field(:secondary_email, :string)
    field(:linkedin, :string)
    field(:twitter, :string)
  end

  @permitted ~w(timezone job_title company company_size industry level state country secondary_email linkedin twitter)a

  def changeset(%__MODULE__{} = metadata, params) do
    metadata |> cast(params, @permitted)
  end
end
