defmodule AcqdatApiWeb.AuthErrorHelper do
  def error_message(:unauthorized) do
    %{
      title: "Invalid credentials",
      error: "Username and password is incorrect.",
      source: nil
    }
  end

  def error_message(:token_error, %ArgumentError{message: message}) do
    %{
      title: "Invalid token",
      error: message,
      source: nil
    }
  end

  def error_message(:token_error, message) do
    %{
      title: "Invalid credentials",
      error: message,
      source: nil
    }
  end
end
