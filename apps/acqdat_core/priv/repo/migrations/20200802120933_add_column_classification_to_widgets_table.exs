defmodule AcqdatCore.Repo.Migrations.AddColumnClassificationToWidgetsTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_widgets") do
      add(:classification, :string, default: "timeseries")
    end

    create index("acqdat_widgets", [:classification])
  end
end
