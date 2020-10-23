defmodule Notifications.Vendors do
  def services(service) do
    case service do
      "twilio" -> :twilio
    end
  end

  def module(:twilio) do
    Elixir.Notifications.Vendors.Twilio
  end
end
