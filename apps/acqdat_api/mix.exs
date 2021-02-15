defmodule AcqdatApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :acqdat_api,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AcqdatApi.Application, []},
      extra_applications: [:logger, :google_maps, :runtime_tools, :gen_retry]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.10"},
      {:phoenix_pubsub, "~> 1.1"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:acqdat_core, in_umbrella: true},

      # authentication
      {:guardian, "~> 2.0"},

      # validation api params
      {:params, "~> 2.0"},

      # cors
      {:corsica, "~> 1.0"},

      # google places
      {:google_maps, "~> 0.11"},

      # sentry logging
      {:sentry, "~> 7.0"},
      {:hackney, "~> 1.8"},
    ]
  end
end
