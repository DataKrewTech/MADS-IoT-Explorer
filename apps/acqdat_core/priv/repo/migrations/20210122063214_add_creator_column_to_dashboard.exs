defmodule AcqdatCore.Repo.Migrations.AddCreatorColumnToDashboard do
  use Ecto.Migration

    def up do
      alter table("acqdat_dashboard") do
        add(:creator_id, references(:users, on_delete: :delete_all))
      end

      create(index("acqdat_dashboard", [:creator_id]))
    end

    def down do
      drop(index("acqdat_dashboard", [:creator_id]))

      alter table("acqdat_dashboard") do
        remove(:creator_id)
      end
    end

end
