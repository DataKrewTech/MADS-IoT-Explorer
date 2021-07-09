defmodule AcqdatApi.RoleManagement.ForgotPassword do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  alias AcqdatCore.Model.RoleManagement.ForgotPassword, as: ForgotPasswordModel
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.RoleManagement.UserCredentials
  alias AcqdatApiWeb.Guardian
  alias AcqdatCore.Repo
  alias AcqdatCore.Mailer
  import Bamboo.Email
  import AcqdatApiWeb.Helpers

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

  def update(user, params) do
    UserCredentials.reset_password(user, params)
  end

  def email(url, user) do
    new_email()
    |> from(@from_address)
    |> to(user.email)
    |> subject(@subject)
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("forgot_password.html", user: user, url: url)
  end

  defp check_user({:ok, user_credentials}) do
    token = generate_token({:ok, user_credentials})

    verify_forgot_password(
      ForgotPasswordModel.create(%{
        token: token,
        user_id: user_credentials.id
      }),
      user_credentials
    )
  end

  defp check_user({:error, message}) do
    {:error, %{error: message}}
  end

  defp verify_forgot_password({:ok, %{token: token, user_id: _user_id}}, user_credentials) do
    url = generate_url(token)
    send_email(url, user_credentials)
    {:ok, url}
  end

  defp verify_forgot_password({:error, forgot_password}, _user_credentials) do
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
    {:ok, access_token, _} =
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
