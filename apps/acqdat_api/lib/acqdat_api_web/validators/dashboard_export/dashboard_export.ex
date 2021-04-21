defmodule AcqdatApiWeb.Validators.DashboardExport.DashboardExport do
  use Params.Schema, %{
    is_secure: [field: :boolean, default: false],
    dashboard_id: :integer,
    password: :string
  }

  import Ecto.Changeset, only: [cast: 3, validate_required: 2]

  @params ~w(is_secure dashboard_id password)a
  @create_required ~w(is_secure dashboard_id)a

  def verify_params(ch, params) do
    ch
    |> cast(params, @params)
    |> validate_required(@create_required)
    |> selective_password_inclusion(params)
  end

  defp selective_password_inclusion(%Ecto.Changeset{valid?: true} = changeset, params) do
    if params["is_secure"] == true  do
      validate_required(changeset, [:password])
    else
      changeset
    end
  end

  defp selective_password_inclusion(%Ecto.Changeset{valid?: false} = changeset, _params) do
    changeset
  end

  @update_required ~w(is_secure)a
  def verify_update_params(ch, params) do
    ch
    |> cast(params, @params)
    |> validate_required(@update_required)
    |> selective_password_inclusion(params)
  end

end
