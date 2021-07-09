defmodule AcqdatCore.Domain.Notification.Server do
  use GenServer
  alias AcqdatCore.Domain.Notification.Worker

  @pool AcqdatCore.Domain.Notification.Manager

  ################ Client Calls #################
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def handle_notification(params) do
    Task.start_link(fn ->
      GenServer.cast(__MODULE__, {:work_arrived, params})
    end)
  end

  def finished(worker) do
    GenServer.cast(__MODULE__, {:finished, worker})
  end

  ################ Server Calls #################

  @impl GenServer
  def init(_) do
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
        Worker.handle_notificaton(worker, args)
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
