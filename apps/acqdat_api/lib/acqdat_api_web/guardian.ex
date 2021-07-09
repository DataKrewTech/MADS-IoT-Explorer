defmodule AcqdatApiWeb.Guardian do
  @moduledoc false

  use Guardian, otp_app: :acqdat_api

  def subject_for_token(nil, _) do
    {:error, :resource_not_found}
  end

  def subject_for_token(resource, _) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(nil) do
    {:error, :no_claims_found}
  end

  def resource_from_claims(claims) do
    user_id = claims["sub"]
    {:ok, user_id}
  end
end
