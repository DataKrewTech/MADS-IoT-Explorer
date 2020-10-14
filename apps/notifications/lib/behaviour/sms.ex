defmodule Notifications.Behaviour.SMS do
  @moduledoc """
  Behaviour for different vendor for sending SMS
  """
  @callback send_sms(message :: String.t(), to :: integer, from :: integer) :: true | false
end
