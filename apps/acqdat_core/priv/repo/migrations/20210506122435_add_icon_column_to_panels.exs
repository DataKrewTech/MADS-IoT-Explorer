defmodule AcqdatCore.Repo.Migrations.AddIconColumnToPanels do
  use Ecto.Migration

  def change do
    alter table("acqdat_panel") do
      add(:icon, :string, default: "home")
    end
  end
end
