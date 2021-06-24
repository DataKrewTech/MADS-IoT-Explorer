defmodule AcqdatCore.Ntools.Kafka do
  @moduledoc  """
  Exposes functions for interacting with kafka.
  """

  alias KafkaEx.Protocol.CreateTopics.TopicRequest
  alias KafkaEx.Protocol.CreateTopics.Response

  defmodule Topic  do
    @enforce_keys ~w(topic_name num_partitions replication_factor)a

    defstruct ~w(topic_name num_partitions replication_factor)a
    @type t :: %__MODULE__{
      topic_name: binary(),
      num_partitions: integer(),
      replication_factor: integer()
    }
  end

  @doc """
  Creates topics in advance for kafka.

  Expects a list of `Topic.t()` structs.

  The map should have following mandatory keys
  `topic_name`, `num_partitions` and `replication factor`

  #TODO: handle creation for multiple topics
  """
  def create_topics(topics) do
    list = create_topics_request(topics)
    %Response{topic_errors: result_list} = KafkaEx.create_topics(list)
    [response] = result_list
    handle_topic_create_response(response)
  end

  defp create_topics_request(topics) do
    Enum.map(topics, fn topic ->
      %TopicRequest{
        topic: topic.topic_name,
        num_partitions: topic.num_partitions,
        replication_factor: topic.replication_factor
      }
    end)
  end

  defp handle_topic_create_response(%{error_code: :no_error}) do
    {:ok, :topic_created}
  end

  defp handle_topic_create_response(%{error_code: error}) do
    {:error, error}
  end
end
