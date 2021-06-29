defmodule AcqdatApi.RoleManagement.ForgotPassword do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  alias AcqdatCore.Model.RoleManagement.ForgotPassword, as: ForgotPasswordModel
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatApiWeb.Guardian
  alias AcqdatCore.Mailer
  import Bamboo.Email
  import AcqdatApiWeb.Helpers

  defdelegate update_user(user, params), to: UserModel
  defdelegate delete(user_id), to: ForgotPasswordModel

  @subject "Reset Password"
  @url Application.get_env(:acqdat_api, :mads_url)
  @access_time_hours 24
  @from_address "mads@datakrew.com"

  def create(params) do
    %{
      email: email
    } = params

    check_user(UserModel.get_by_email(email))
  end

  def email(url, user) do
    new_email()
    |> from(@from_address)
    |> to(user.user_credentials.email)
    |> subject(@subject)
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("forgot_password.html", user: user, url: url)
  end

  defp check_user({:ok, user}) do
    token = generate_token(get(user.id))

    verify_forgot_password(
      ForgotPasswordModel.create(%{
        token: token,
        user_id: user.id
      })
    )
  end

  defp check_user({:error, message}) do
    {:error, %{error: message}}
  end

  defp verify_forgot_password({:ok, %{token: token, user_id: user_id}}) do
    url = generate_url(token)
    {:ok, user} = get(user_id)
    send_email(url, user)
    {:ok, url}
  end

  defp verify_forgot_password({:error, forgot_password}) do
    {:error, %{error: extract_changeset_error(forgot_password)}}
  end

  defp generate_token({:ok, user}) do
    guardian_create_token(
      user,
      {@access_time_hours, :hours},
      :access
    )
  end

  defp guardian_create_token(resource, time, token_type) do
    {:ok, access_token, _claims} =
      Guardian.encode_and_sign(
        resource,
        %{},
        token_type: token_type,
        ttl: time
      )

    access_token
  end

  defp get(user_id) do
    UserModel.get(user_id)
  end

  defp generate_url(token) do
    trailing_part = "reset_password?token=#{token}"
    @url <> trailing_part
  end

  defp send_email(url, user) do
    email(url, user)
    |> Mailer.deliver_now()
  end
end
