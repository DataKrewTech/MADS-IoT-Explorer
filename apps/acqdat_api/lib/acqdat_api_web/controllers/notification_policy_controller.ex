defmodule AcqdatApiWeb.NotificationPolicyController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.SensorNotification, as: SensorNotificationModel
  import AcqdatApiWeb.Helpers

  def index(conn, _params) do
    with {:list, [policies]} = {:list, SensorNotificationModel.get_policies_with_preferences()} do
      conn
      |> put_status(200)
      |> render("policy.json", policies: policies)
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)
    end
  end
end
