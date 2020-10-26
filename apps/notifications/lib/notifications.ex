defmodule Notifications do
  @moduledoc """
    For sending alert notifications in different modes.
  """
  alias AcqdatCore.Model.RoleManagement.User
  alias AcqdatCore.Mailer.AlertNotification
  alias AcqdatCore.Mailer
  alias AcqdatCore.Model.EntityManagement.Organisation
  alias Notifications.Vendors

  def send_notifications(alert, alert_rule, vendor) do
    Enum.each(alert.communication_medium, fn medium ->
      case medium do
        "e-mail" -> send_alert(alert)
        "sms" -> send_sms(alert, alert_rule, vendor)
        "whatsapp" -> send_message(alert, alert_rule, vendor)
        "in-app" -> nil
      end
    end)
  end

  def send_alert(alert) do
    Enum.each(alert.recepient_ids, fn recipient ->
      if recipient != 0 do
        user = User.extract_email(recipient)

        AlertNotification.email(user.email, alert, user)
        |> Mailer.deliver_now()
      end
    end)
  end

  defp send_sms(alert, alert_rule, vendor) do
    contacts = create_contact_list(alert_rule)
    message = create_message(alert)

    case List.first(contacts) do
      nil ->
        nil

      _ ->
        Enum.each(contacts, fn contact ->
          Vendors.module(Vendors.services(vendor)).send_sms(message, contact, "+12059646511")
        end)
    end
  end

  defp send_message(alert, alert_rule, vendor) do
    contacts = create_contact_list(alert_rule)
    message = create_message(alert)

    case List.first(contacts) do
      nil ->
        nil

      _ ->
        Enum.each(contacts, fn contact ->
          Vendors.module(Vendors.services(vendor)).send_message(
            message,
            contact,
            "+14155238886"
          )
        end)
    end
  end

  defp create_message(alert) do
    "Hello,
    An alert has been generated in your MADS workspace on #{alert.inserted_at}.

    Below are the details:-

    App: #{alert.alert_app_name}
    Alert Rule: #{alert.name}
    Condition: #{Atom.to_string(alert.policy_name)}
    Severity: #{alert.severity_code}(#{Atom.to_string(alert.severity)}

    Thank you.
    Regards,
    MADSbot
    "
  end

  defp create_contact_list(alert_rule) do
    user_phone_numbers =
      Enum.reduce(alert_rule.recepient_ids, [], fn recipient, acc ->
        if recipient != 0 do
          user = User.extract_email(recipient)
          acc ++ [user.phone_number]
        end
      end)

    user_phone_numbers ++ alert_rule.phone_numbers
  end
end
