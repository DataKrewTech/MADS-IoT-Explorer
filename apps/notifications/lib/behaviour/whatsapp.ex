defmodule Notifications.Behaviour.Whatsapp do
  @moduledoc """
  Behaviour for different vendor for sending SMS
  """
  @callback send_message(message :: String.t(), to :: integer, from :: integer) :: map
end
