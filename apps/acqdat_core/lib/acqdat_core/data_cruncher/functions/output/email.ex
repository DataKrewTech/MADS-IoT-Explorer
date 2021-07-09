defmodule AcqdatCore.DataCruncher.Functions.Email do
  alias AcqdatCore.Mailer.DataCruncherEmail
  alias AcqdatCore.Mailer

  @inports [:ts_datasource]
  @outports [:tsemail]
  # @display_name "Send Email"
  # @properties %{}
  # @category :output
  # @info """
  # Function sends the email as output node
  # """

  use Virta.Component

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    result = Map.get(inport_args, :ts_datasource)

    result
    |> process_data()

    return_reply_message(result, request_id)
  end

  defp return_reply_message(result, request_id) do
    {request_id, :reply, %{tsemail: result}}
  end

  defp process_data(result) do
    # TODO: Need to do proper data parsing, before sensing it to mailer, also needs to consider current_user details
    current_user = "gdkjrkg"
    # Mailer.deliver_later()
    DataCruncherEmail.email(current_user, result)
    |> Mailer.deliver_now()
  end
end
