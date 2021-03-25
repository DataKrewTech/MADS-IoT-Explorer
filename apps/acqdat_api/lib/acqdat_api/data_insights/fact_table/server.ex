defmodule AcqdatApi.DataInsights.FactTableServer do
  use GenServer

  alias AcqdatApi.DataInsights.FactTableWorker

  @pool AcqdatApi.DataInsights.FactTableManager

  ################ Client Calls #################
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def process(params) do
    GenServer.cast(__MODULE__, {:work_arrived, params})
  end

  @doc """
  The `finished` function is used by the worker to indicate it's work is finished.

  On finishing the work the worker is returned back to the pool and queue draining
  process is started again.
  """
  def finished(worker) do
    GenServer.cast(__MODULE__, {:finished, worker})
  end

  ################ Server Calls #################

  @impl GenServer
  def init(_args) do
    {:ok, %{queue: :queue.new()}}
  end

  @impl GenServer
  def handle_cast({:work_arrived, params}, %{queue: queue} = state) do
    queue = enqueue(queue, params)
    {_, queue} = drain_queue(@pool, queue)

    {:noreply, %{state | queue: queue}}
  end

  def handle_cast({:finished, worker}, %{queue: queue} = state) do
    :poolboy.checkin(@pool, worker)
    {_, queue} = drain_queue(@pool, queue)

    {:noreply, %{state | queue: queue}}
  end

  ############# private functions ###############

  defp drain_queue(pool, queue) do
    case :poolboy.status(pool) do
      {:ready, _, _, _} ->
        do_work(pool, queue)

      {:overflow, _, _, _} ->
        do_work(pool, queue)

      {:full, _, _, _} ->
        # warn "pool exhausted, stopping drain"
        {:exhausted, queue}
    end
  end

  defp do_work(pool, queue) do
    case queue_next(queue) do
      {:ok, args, queue} ->
        worker = :poolboy.checkout(pool)
        FactTableWorker.process(worker, args)
        drain_queue(pool, queue)

      {:empty, _queue} = result ->
        # debug "queue empty, stopping drain"
        result
    end
  end

  defp queue_next(queue) do
    case :queue.out(queue) do
      {{:value, item}, queue} ->
        {:ok, item, queue}

      {:empty, _queue} = result ->
        result
    end
  end

  defp enqueue(queue, item) do
    :queue.in(item, queue)
  end
end
