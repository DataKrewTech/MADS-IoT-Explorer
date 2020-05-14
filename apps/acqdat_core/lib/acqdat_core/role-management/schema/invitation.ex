defmodule AcqdatCore.Schema.RoleManagement.Invitation do
  @moduledoc """
  Models a user Invitation in acqdat.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{Role, User}
  alias AcqdatCore.Schema.EntityManagement.Organisation

  @type t :: %__MODULE__{}

  schema("acqdat_invitations") do
    field(:email, :string, null: false)
    field(:token, :string, null: false)
    field(:token_valid, :boolean, default: true)
    field(:salt, :string, null: false)
    field(:asset_ids, {:array, :integer})
    field(:app_ids, {:array, :integer})

    # associations
    belongs_to(:inviter, User, on_replace: :delete)
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:role, Role)

    timestamps(type: :utc_datetime)
  end

  @required ~w(email token salt inviter_id org_id role_id)a
  @optional ~w(asset_ids app_ids token_valid)a
  @permitted @optional ++ @required

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = invitation, params) do
    invitation
    |> cast(params, @permitted)
    |> gen_token(params)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> unique_constraint(:token)
    |> unique_constraint(:salt)
    |> assoc_constraint(:inviter)
    |> assoc_constraint(:org)
  end

  def update_changeset(%__MODULE__{} = invitation, params) do
    invitation
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> unique_constraint(:token)
    |> unique_constraint(:salt)
    |> assoc_constraint(:inviter)
    |> assoc_constraint(:org)
  end

  # NOTE: Currently following this for token generation: https://hexdocs.pm/phoenix/1.4.8/Phoenix.Token.html#module-example
  defp gen_token(changeset, params) do
    %{
      "email" => email,
      "org_id" => org_id
    } = params

    str = "#{email}#{org_id}"

    # NOTE: Genereted Salt is Random, taken reference from https://github.com/phoenixframework/phoenix/blob/3b9fca11b6a4d6a61ac3ca9163b876e9cdd11dc7/lib/mix/tasks/phoenix.gen.secret.ex#L26
    user_salt =
      String.length(str)
      |> :crypto.strong_rand_bytes()
      |> Base.encode32()
      |> binary_part(0, String.length(str))

    token = Phoenix.Token.sign(AcqdatApiWeb.Endpoint, user_salt, %{email: email, org_id: org_id})

    changeset
    |> put_change(:salt, user_salt)
    |> put_change(:token, token)
    |> put_change(:token_valid, true)
  end
end
