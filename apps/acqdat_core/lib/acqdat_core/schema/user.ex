defmodule AcqdatCore.Schema.User do
  @moduledoc """
  Models a user in acqdat.
  """

  use AcqdatCore.Schema
  alias Comeonin.Argon2
  alias AcqdatCore.Schema.{Role, UserSetting, Organisation, Asset, App}
  alias AcqdatCore.Repo
  import Ecto.Query

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
    belongs_to(:role, Role)
    has_one(:user_setting, UserSetting)
    many_to_many(:assets, Asset, join_through: "asset_user", on_replace: :delete)
    many_to_many(:apps, App, join_through: "app_user", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(first_name email password is_invited password_confirmation role_id org_id)a
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

    # |> associate_assets_changeset(params[:asset_ids] || [])
    # |> associate_apps_changeset(params[:apps_ids] || [])
  end

  def associate_asset_changeset(user, assets) do
    user
    |> Repo.preload(:assets)
    |> change()
    |> put_assoc(:assets, assets)
  end

  def associate_app_changeset(user, apps) do
    user
    |> Repo.preload(:apps)
    |> change()
    |> put_assoc(:apps, apps)
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
