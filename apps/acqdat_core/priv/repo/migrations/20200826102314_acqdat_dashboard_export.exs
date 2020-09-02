defmodule AcqdatCore.Repo.Migrations.AddAcqdatDashboardExport do
  @moduledoc """
  Migration for storing details related to dashboard that is exported and their type(public/private)
  """
  use Ecto.Migration

  def change do
    create table("acqdat_dashboard_export") do
      add(:token, :text)
      add(:is_secure, :boolean, null: false, default: false)
      add(:password, :string)
      add(:dashboard_uuid, :string, null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_dashboard_export", [:dashboard_uuid], name: :restrict_already_exported_dashboard)
  end
end
