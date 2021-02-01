defmodule AcqdatCore.Repo.Migrations.AddDashboardOpenedBy do
  use Ecto.Migration

  def change do
    alter table("acqdat_dashboard") do
      add(:opened_on, :utc_datetime)
    end
  end
end
