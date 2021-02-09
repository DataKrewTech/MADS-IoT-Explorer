defmodule AcqdatApiWeb.AuthErrorHelper do
  def error_message(:unauthorized) do
    %{
      title: "Invalid credentials",
      error: "Username and password is incorrect.",
      source: nil
    }
  end
end
