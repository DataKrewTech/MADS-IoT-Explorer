defmodule AcqdatCore.Repo.Migrations.CreateTableWkflowOutput do
  use Ecto.Migration

  def change do
    create table("acqdat_wkflow_output") do
      add(:format, :string)
      add(:source_id, :string)
      add(:data, :map)
      add(:async, :boolean, default: false)
      add(:workflow_id, references("acqdat_workflows", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end
  end
end
