defmodule AcqdatCore.Repo.Migrations.AcqdataUserCredentials do
  use Ecto.Migration
  alias AcqdatCore.Seed.RoleManagement.UserDetails
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.RoleManagement.UserCredentials
  alias AcqdatCore.Repo
  import Ecto.Query

  def change do
    # create table("acqdat_user_credentials") do
    #   add(:first_name, :string, null: false)
    #   add(:last_name, :string)
    #   add(:email, :citext, null: false)
    #   add(:password_hash, :string, null: false)
    #   add(:phone_number, :string)

    #   timestamps(type: :timestamptz)
    # end

    # create unique_index("acqdat_user_credentials", [:email])
    # flush()

    # alter table("users") do
    #   add(:user_credentials_id, references("acqdat_user_credentials"))
    #   end

    #   create(index(:users, [:user_credentials_id]))
    # flush()
  end
end

defmodule AcqdatCore.Repo.Migrations.AddUserDetails do
  # use Ecto.Migration
  # alias AcqdatCore.Seed.RoleManagement.UserDetails
  # alias AcqdatCore.Schema.RoleManagement.User
  # alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  # alias AcqdatCore.Model.RoleManagement.UserCredentials
  # alias AcqdatCore.Repo
  # import Ecto.Query

  def change do


    # query =
    #   from(usr in "users",
    #   select: usr)

    # query
    # |> Repo.all()
    # |> Enum.each(fn user ->
    #   details = [user.first_name, user.last_name, user.email, user.password_hash, user.phone_number]
    #   user_credentials = create_user_credentials(details)
    #   params = %{user_credentials_id: user_credentials.id}
    #   UserModel.update_user(user, params)
    # end)
  end

  # defp create_user_credentials([first_name, last_name, email, password_hash, phone_number]) do
  #   params = %{
  #     first_name: first_name,
  #     last_name: last_name,
  #     email: email,
  #     password_hash: password_hash,
  #     phone_number: phone_number
  #   }
  #   {:ok, user_cred} = UserCredentials.create(params)
  #   user_cred
  # end
end

# # defmodule AcqdatCore.Repo.Migrations.DropUserDetails do
#   #   use Ecto.Migration

#   #   def up do
#   #     alter table("users") do
#   #       remove(:first_name)
#   #       remove(:last_name)
#   #       remove(:email)
#   #       remove(:password_hash)
#   #       remove(:phone_number)
#   #     end
#   #   end

#   #   def down do
#   #     alter table("users") do
#   #       add(:first_name, :string)
#   #       add(:last_name, :string)
#   #       add(:email, :citext)
#   #       add(:password_hash, :string)
#   #       add(:phone_number, :string)
#   #     end
#   #   end
#   # end
