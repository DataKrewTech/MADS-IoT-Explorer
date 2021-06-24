defmodule AcqdatCore.StreamLogic.Model.ConsumerGroup do
  @moduledoc """
  A module for creating consumer group per logic chain.

  At present each logic chain is represented as a consumer group with only one
  consumer. `Kafka_ex` doesn't support standalone consumers at this time. Hence,
  each chain has been represented as a consumer group.
  """

  import Supervisor.Spec
  alias AcqdatCore.StreamLogic.ConsumerSupervisor
  alias AcqdatCore.StreamLogic.Model.Consumer

  def start_consumer_group(name, topic) do
    consumer_group_opts = [
      # setting for the ConsumerGroup
      heartbeat_interval: 1_000,
      # this setting will be forwarded to the GenConsumer
      commit_interval: 1_000
    ]

    gen_consumer_impl = Consumer
    consumer_group_name = name
    topic_names = [topic]

    #TODO: Uses old child spec, modify it to use new child spec.
    child_spec = supervisor(
      KafkaEx.ConsumerGroup,
      [gen_consumer_impl, consumer_group_name, topic_names, consumer_group_opts]
    )

    DynamicSupervisor.start_child(
      ConsumerSupervisor,
      child_spec
    )
  end
end
