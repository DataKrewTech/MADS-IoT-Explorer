defmodule AcqdatCore.StreamLogic.Model.Consumer do
  use KafkaEx.GenConsumer

  def handle_message_set(message_set, state) do
    {:async_commit, state}
  end
end
