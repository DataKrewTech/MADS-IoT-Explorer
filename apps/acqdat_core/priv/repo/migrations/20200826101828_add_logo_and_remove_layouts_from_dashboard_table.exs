defmodule AcqdatCore.Repo.Migrations.AddLogoAndRemoveLayoutsFromDashboardTable do
  use Ecto.Migration

  def up do
    alter table("acqdat_dashboard") do
      remove(:widget_layouts)
      add(:avatar, :string)
    end
  end

  def down do
    alter table("acqdat_dashboard") do
      remove(:avatar)
      add(:widget_layouts, :map)
    end
  end
end
