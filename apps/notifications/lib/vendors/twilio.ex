defmodule Notifications.Vendors.Twilio do
  @moduledoc """
    Twilio service will be used to send the notification of alert in form of sms or in whatsapp
  """
  alias Notifications.Behaviour.Whatsapp
  alias Notifications.Behaviour.SMS
  @behaviour Whatsapp
  @behaviour SMS

  # ExTwilio.Message.create(to: "whatsapp:+917066820264", from: "whatsapp:+14155238886", body: "Hello there mads is  going great")
  @impl
  def send_message(message, to, from) do
    ExTwilio.Message.create(to: to, from: from, body: message)
  end

  @impl
  def send_sms(message, to, from) do
    ExTwilio.Message.create(to: to, from: from, body: message)
  end
end
