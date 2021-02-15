defmodule AcqdatCore.IotManager.DataDump.RedisErrorHandler do
  @moduledoc """
  Exposes functions for handling errors related to gateway data dump.

  While adding data for a gateway errors may happen due to multiple reason
  such as:
  * `duplicate timestamp`
  * `non existent project, org or gateway id`

  Redis temporarily stores the error per gateway so as to inform the
  client about respective corrections.
  """
  @name :redix_gateway_error
  @redis_port Application.get_env(:acqdat_core, :redis_port)

  @doc """
  Starts a process to interact with redis for error related storage.

  This will start the process under the redis supervisor.
  """
  def child() do
    {Redix, {@redis_port, name: @name}}
  end

end
