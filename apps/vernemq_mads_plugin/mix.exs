defmodule VernemqMadsPlugin.MixProject do
  use Mix.Project

  def project do
    [
      app: :vernemq_mads_plugin,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        vernemq_mads_plugin: [
          applications: [
            vernemq_mads_plugin: :permanent
          ],
          include_erts: false
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {VernemqMadsPlugin.Application, []},
      env: [
        vmq_plugin_hooks(),
        database_creds(),
        read_repo: VernemqMadsPlugin.Repo
      ]
    ]
  end

  defp vmq_plugin_hooks do
    hooks = [
      {VernemqMadsPlugin, :auth_on_register, 5, []},
      {VernemqMadsPlugin, :on_register, 3, []},
      {VernemqMadsPlugin, :on_client_wakeup, 1, []},
      {VernemqMadsPlugin, :on_client_offline, 1, []},
      {VernemqMadsPlugin, :on_client_gone, 1, []},
      {VernemqMadsPlugin, :auth_on_subscribe, 3, []},
      {VernemqMadsPlugin, :on_subscribe, 3, []},
      {VernemqMadsPlugin, :on_unsubscribe, 3, []},
      {VernemqMadsPlugin, :auth_on_publish, 6, []},
      {VernemqMadsPlugin, :on_publish, 6, []},
      {VernemqMadsPlugin, :on_deliver, 4, []},
      {VernemqMadsPlugin, :on_offline_message, 5, []}
    ]

    {:vmq_plugin_hooks, hooks}
  end

  defp database_creds() do
    {
      VernemqMadsPlugin.Repo,
      [
        adapter: Ecto.Adapters.Postgres,
        username: System.get_env("DB_USER", "postgres"),
        password: System.get_env("DB_PASSWORD", "postgres"),
        database: "acqdat_core_dev",
        hostname: System.get_env("DB_HOST", "localhost"),
        port: System.get_env("DB_PORT", "5432"),
        pool_size: 10
      ]
    }
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
      {:ecto_sql, "~> 3.2.0"},
      {:postgrex, ">= 0.0.0"},
      {:acqdat_core, in_umbrella: true, only: :test}
    ]
  end
end
