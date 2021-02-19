defmodule AcqdatApiWeb.RoleManagement.RoleManagementErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Entity does not exists. ",
      error:
        "Either the resource requested doesn't exists or you don't have permission to access it.",
      source: nil
    }
  end

  def error_message(:resource_not_found_role) do
    %{
      title: "Data is invalid",
      error: "Some problem with indexing of role management API",
      source: nil
    }
  end

  def error_message(:unauthorized) do
    %{
      title: "Unauthorized Access",
      error: "You are not allowed to perform this action.",
      source: nil
    }
  end

  def confirm_message(:mail_sent) do
    %{
      status_code: 200,
      title: "Forgot Password mail sent",
      detail: "Password email containing further process to reset your password has been sent.",
      source: nil
    }
  end

  def error_message(:forgot_password, message) do
    %{
      status_code: 400,
      title: "Problem with sending email or the email provided is wrong",
      detail: message,
      source: nil
    }
  end

  def error_message(:forgot_password, message) do
    %{
      status_code: 400,
      title: "Problem with sending email or the email provided is wrong",
      detail: message,
      source: nil
    }
  end

  def error_message(:wrong_email) do
    %{
      title: "Wrong Email or Invalid Email",
      error: "Email provided is either wrong or no such user exists.",
      source: nil
    }
  end

  def error_message(:unauthorized_link) do
    %{
      title: "Invalid or expired link.",
      error: "The link you are trying to access is either invalid or expired.",
      source: nil
    }
  end

  def confirm_message(:reset_success) do
    %{
      status_code: 200,
      title: "Password reset success.",
      detail: "Password has changes successfully updated.",
      source: nil
    }
  end
end
