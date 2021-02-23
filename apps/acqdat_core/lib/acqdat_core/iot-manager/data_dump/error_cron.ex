defmodule AcqdatCore.IotManager.DataDump.ErrorCron do
  @moduledoc """
  Runs a cron task which removes errors older than a week automatically.

  Errors should ideally be acknowledged by users however if they are not they are
  automatically removed after a week.
  """

  use GenServer
  alias AcqdatCore.Model.IotManager.GatewayDataDump

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
    GatewayDataDump.delete_errors(Timex.now(:utc))

    {:noreply, state, {:continue, :schedule_next_run}}
  end

  # this callback triggers on any continue tuple
  def handle_continue(:schedule_next_run, state) do
    next_run_delay = calculate_next_cycle_delay(Timex.now())
    Process.send_after(self(), :remove_errors, next_run_delay)
    {:noreply, state}
  end

  defp calculate_next_cycle_delay(now) do
    now
    |> Timex.set(hour: 6, minute: 0, second: 0)
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
