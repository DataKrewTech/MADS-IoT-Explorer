defmodule Notifications.Vendors.Twilio do
  @moduledoc """
    Twilio service will be used to send the notification of alert in form of sms or in whatsapp
  """
  alias Notifications.Behaviour.Whatsapp
  alias Notifications.Behaviour.SMS
  @behaviour Whatsapp
  @behaviour SMS

  # ExTwilio.Message.create(to: "whatsapp:+917066820264", from: "whatsapp:+14155238886", body: "Hello there mads is  going great")
  # @impl
  @spec send_message(any, any, any) :: {:ok, map} | {:error, map, number}
  def send_message(message, to, _from) do
    ExTwilio.Message.create(to: "whatsapp:#{to}", from: "whatsapp:+14155238886", body: message)
  end

  # @impl
  @spec send_sms(any, any, any) :: {:ok, map} | {:error, map, number}
  def send_sms(message, to, from) do
    ExTwilio.Message.create(to: to, from: from, body: message)
  end
end
