defmodule AcqdatCore.Repo.Migrations.AssociateUserCredentialsAndUserSettings do
  import Ecto.Query
  use Ecto.Migration
  alias AcqdatCore.Model.RoleManagement.UserSetting
  alias AcqdatCore.Repo

  def up do
    alter table("user_settings") do
      add(:user_credentials_id, references(:acqdat_user_credentials, on_delete: :delete_all))
    end

    flush()

    UserSetting.fetch_user_credentials()
    |> Enum.each(fn {user_settings_id, user_credentials_id} ->
      query =
        from(us in "user_settings",
          where: us.id == ^user_settings_id,
          update: [set: [user_credentials_id: ^user_credentials_id]]
        )

      Repo.update_all(query, [])
    end)

    alter table("user_settings") do
      remove(:user_id)
    end
  end

  def down do
    alter table("user_settings") do
      add(:user_id, references(:users, on_delete: :delete_all))
      remove(:user_credentials_id)
    end
  end
end
