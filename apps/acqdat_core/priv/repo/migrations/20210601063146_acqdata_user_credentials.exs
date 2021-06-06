defmodule AcqdatCore.Repo.Migrations.AcqdataUserCredentials do
  use Ecto.Migration
  alias AcqdatCore.Seed.RoleManagement.UserDetails
  alias AcqdatCore.Schema.RoleManagement.TempUser
  alias AcqdatCore.Schema.RoleManagement.UserCredentials
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.RoleManagement.UserCredentials, as: UCModel
  alias AcqdatCore.Repo
  import Ecto.Query

  def up do
    create table("acqdat_user_credentials") do
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :citext, null: false)
      add(:password_hash, :string, null: false)
      add(:phone_number, :string)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_user_credentials", [:email])
    flush()

    alter table("users") do
      add(:user_credentials_id, references("acqdat_user_credentials"))
    end

    create(index(:users, [:user_credentials_id]))
    flush()

    query =
      from(usr in TempUser,
      select: usr)

    query
    |> Repo.all()
    |> Enum.each(fn user ->
      details = [user.first_name, user.last_name, user.email, user.password_hash, user.phone_number]
      user_credentials = create_user_credentials(details)
      params = %{user_credentials_id: user_credentials.id}
      changeset = TempUser.update_changeset(user, params)
      Repo.update(changeset)
    end)

    alter table("users") do
      remove(:first_name)
      remove(:last_name)
      remove(:email)
      remove(:password_hash)
      remove(:phone_number)
    end
  end

  def down do
    alter table("users") do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :citext)
      add(:password_hash, :string)
      add(:phone_number, :string)
    end
    transfer_user_credentials_data_to_user()
    drop index(:users, [:user_credentials_id])
    drop unique_index("acqdat_user_credentials", [:email])
    alter table("users") do
      remove(:user_credentials_id)
    end
    drop table("acqdat_user_credentials")
  end

  defp transfer_user_credentials_data_to_user() do
    query =
      from(usr in UserCredentials,
      select: usr)
   query
    |> Repo.all()
    |> Enum.each(fn user ->
      params = [first_name: user.first_name, last_name: user.last_name, email: user.email, password_hash: user.password_hash, phone_number: user.phone_number]
      query = from(usr in TempUser,
        where: usr.user_credentials_id == ^user.id)
      query
      |> Repo.update_all(set: params)
    end)
  end

  defp create_user_credentials([first_name, last_name, email, password_hash, phone_number]) do
    params = %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      password_hash: password_hash,
      phone_number: phone_number
    }
    {:ok, user_cred} = UCModel.create(params)
    user_cred
  end
end
