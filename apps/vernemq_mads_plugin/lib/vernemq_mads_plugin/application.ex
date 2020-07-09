defmodule VernemqMadsPlugin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    IO.puts("Starting mads plugin")
    children = [
      # Starts a worker by calling: VernemqMadsPlugin.Worker.start_link(arg)
      # {VernemqMadsPlugin.Worker, arg}
      VernemqMadsPlugin.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VernemqMadsPlugin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
