defmodule AcqdatCore.Schema.Invitation do
  @moduledoc """
  Models a user Invitation in acqdat.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.User

  @type t :: %__MODULE__{}

  schema("acqdat_invitations") do
    # TODO: Need to add role as well as team associations
    field(:email, :string, null: false)
    field(:token, :string, null: false)
    field(:asset_ids, {:array, :integer})
    field(:app_ids, {:array, :integer})

    # associations
    belongs_to(:inviter, User)

    timestamps(type: :utc_datetime)
  end

  @required ~w(email token inviter_id)a
  @optional ~w(asset_ids app_ids)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = invitation, params) do
    invitation
    |> cast(params, @permitted)
    |> genToken(params)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> assoc_constraint(:inviter)
  end

  defp genToken(changeset, params) do
    %{
      "email" => email
    } = params

    # TODO: Need to add team name in the String.length
    token =
      String.length(email)
      |> :crypto.strong_rand_bytes()
      |> Base.encode32()
      |> binary_part(0, String.length(email))

    put_change(changeset, :token, token)
  end
end
