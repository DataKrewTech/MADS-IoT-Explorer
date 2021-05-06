defmodule AcqdatApiWeb.Validators.DashboardExport.DashboardExport do
  use Params.Schema, %{
    is_secure: [field: :boolean, default: false],
    dashboard_id: :integer,
    password: :string
  }

  import Ecto.Changeset

  @params ~w(is_secure dashboard_id password)a
  @create_required ~w(is_secure dashboard_id)a

  def verify_params(ch, params) do
    ch
    |> cast(params, @params)
    |> validate_required(@create_required)
    |> selective_password_inclusion()
  end

  defp selective_password_inclusion(%Ecto.Changeset{valid?: true} = changeset) do
    is_secure = get_field(changeset, :is_secure)

    if is_secure == true do
      validate_required(changeset, [:password])
    else
      changeset
    end
  end

  defp selective_password_inclusion(%Ecto.Changeset{valid?: false} = changeset) do
    changeset
  end

  @update_required ~w(is_secure)a
  def verify_update_params(ch, params) do
    ch
    |> cast(params, @params)
    |> validate_required(@update_required)
    |> selective_password_inclusion()
  end
end
