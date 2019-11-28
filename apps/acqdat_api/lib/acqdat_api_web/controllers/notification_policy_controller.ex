defmodule AcqdatApiWeb.NotificationPolicyController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.SensorNotification, as: SensorNotificationModel

  def index(conn, _params) do
    with {:list, policies} = {:list, SensorNotificationModel.get_policies_with_preferences()} do
      conn
      |> put_status(200)
      |> render("policies.json", policies: policies)
    end
  end
end
