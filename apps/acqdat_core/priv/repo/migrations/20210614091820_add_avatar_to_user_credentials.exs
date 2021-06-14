defmodule AcqdatCore.Repo.Migrations.AddAvatarToUserCredentials do
  import Ecto.Query
  use Ecto.Migration
  alias AcqdatCore.Repo

  def up do
    alter table("acqdat_user_credentials") do
      add(:avatar, :string)
    end

    flush()

    query = from(user in "users", join: cred in "acqdat_user_credentials",
      on: user.user_credentials_id == cred.id,
      select: {
        user.avatar,
        cred.id
      })

    query
    |> Repo.all()
    |> Enum.each(fn {avatar, credential_id} ->
      query =
        from(us in "acqdat_user_credentials",
          where: us.id == ^credential_id,
          update: [set: [avatar: ^avatar]]
        )

      Repo.update_all(query, [])
    end)

    alter table("users") do
      remove(:avatar)
    end
  end

  def down do
    alter table("users") do
      add(:avatar, :string)
    end

    flush()

    query = from(user in "users", join: cred in "acqdat_user_credentials",
      on: user.user_credentials_id == cred.id,
      select: {
        cred.avatar,
        user.id
      })

    query
    |> Repo.all()
    |> Enum.each(fn {avatar, user_id} ->
      query =
        from(us in "users",
          where: us.id == ^user_id,
          update: [set: [avatar: ^avatar]]
        )

      Repo.update_all(query, [])
    end)

    alter table("acqdat_user_credentials") do
      remove(:avatar)
    end
  end
end
