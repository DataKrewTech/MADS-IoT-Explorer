defmodule AcqdatCore.Repo.Migrations.CreateTableTempOutput do
  use Ecto.Migration

  def change do
    create table("acqdat_temp_output") do
      add(:format, :string)
      add(:data, {:array, :map})
      add(:async, :boolean, default: false)
      add(:workflow_id, references("acqdat_workflows", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end
  end
end
