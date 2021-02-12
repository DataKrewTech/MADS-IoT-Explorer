defmodule AcqdatCore.Schema.RoleManagement.User do
  @moduledoc """
  Models a user in acqdat.
  """

  use AcqdatCore.Schema
  import Ecto.Query
  alias Comeonin.Argon2
  alias AcqdatCore.Schema.EntityManagement.{Asset, Organisation}
  alias AcqdatCore.Schema.RoleManagement.{App, Role, UserSetting, GroupUser}
  alias AcqdatCore.Repo

  @password_min_length 8
  @type t :: %__MODULE__{}

  schema("users") do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:avatar, :string)
    field(:is_deleted, :boolean, default: false)
    field(:phone_number, :string)
    field(:is_invited, :boolean, default: false)
    field(:password_hash, :string)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:role, Role)
    has_one(:user_setting, UserSetting)
    has_many(:user_group, GroupUser)
    many_to_many(:assets, Asset, join_through: "asset_user", on_replace: :delete)
    many_to_many(:apps, App, join_through: "app_user", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(first_name email password is_invited password_confirmation role_id org_id)a
  @optional ~w(password_hash is_deleted phone_number last_name avatar)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common_changeset(params)
    |> add_apps_changeset(params[:app_ids] || [])
    |> add_assets_changeset(params[:asset_ids] || [])
  end

  def update_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @permitted)
    |> common_changeset(params)
  end

  def common_changeset(changeset, _params) do
    changeset
    |> unique_constraint(:email, name: :users_email_index)
    |> validate_confirmation(:password)
    |> validate_length(:password, min: @password_min_length)
    |> validate_format(:email, ~r/@/)
    |> put_pass_hash()
    |> assoc_constraint(:org)
    |> assoc_constraint(:role)
  end

  defp add_apps_changeset(user, app_ids) do
    apps = Repo.all(from(app in App, where: app.id in ^app_ids))

    user
    |> put_assoc(:apps, Enum.map(apps, &change/1))
  end

  defp add_assets_changeset(user, asset_ids) do
    assets = Repo.all(from(asset in Asset, where: asset.id in ^asset_ids))

    user
    |> put_assoc(:assets, Enum.map(assets, &change/1))
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
