defmodule AcqdatCore.Repo.Migrations.AcqdatGroupPolicies do
  use Ecto.Migration

  def change do
    create table("acqdat_group_policies") do
      add(:group_id, references("acqdat_groups", on_delete: :delete_all), null: false)
      add(:policy_id, references("acqdat_policies", on_delete: :restrict), null: false)
      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_group_policies", [:policy_id, :group_id])
  end
end
