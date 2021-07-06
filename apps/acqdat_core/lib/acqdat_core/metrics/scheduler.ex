defmodule AcqdatCore.Metrics.SchedulerSupervisor do
  use Supervisor

  @moduledoc """
  Acts as the supervisor process for the scheduler
  """

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      AcqdatCore.Metrics.Scheduler
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule AcqdatCore.Metrics.Scheduler do

  @moduledoc """
  Runs a cron task to add the metrics for an organisation in the metrics table.
  """
  use GenServer
  alias AcqdatCore.Metrics.OrgMetrics

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  ######################### server callbacks #######################

  def init(_) do
    # return a continue tuple last to schedule on process boot
    {:ok, %{}, {:continue, :schedule_next_run}}
  end

  def handle_info(:remove_errors, state) do
    OrgMetrics.measure_and_dump()

    {:noreply, state, {:continue, :schedule_next_run}}
  end

  # this callback triggers on any continue tuple
  def handle_continue(:schedule_next_run, state) do
    next_run_delay = calculate_next_cycle_delay(Timex.now())
    Process.send_after(self(), :remove_errors, next_run_delay)
    {:noreply, state}
  end

  #TODO: The time is being set to 11:45 pm singapore time which is
  #      3:45pm UTC. This should be a configurable time so it can run as per
  #      the cloud region.
  defp calculate_next_cycle_delay(now) do
    now
    |> Timex.set(hour: 15, minute: 45, second: 0)
    |> maybe_shift_a_day(now)
    |> Timex.diff(now, :milliseconds)
  end

  defp maybe_shift_a_day(next_run, now) do
    case Timex.before?(now, next_run) do
      true ->
        next_run

      false ->
        Timex.shift(next_run, days: 1)
    end
  end

end
