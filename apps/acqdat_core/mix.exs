defmodule AcqdatCore.MixProject do
  use Mix.Project

  def project do
    [
      app: :acqdat_core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {AcqdatCore.Application, []},
      extra_applications: [:logger, :arc_ecto, :scrivener_ecto, :virta]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/repo/seed/"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.2.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},

      # auth
      {:comeonin, "~> 4.1.1"},
      {:argon2_elixir, "~> 1.2"},

      # neseted sets
      {:as_nested_set, "~> 3.2"},

      # Pagination
      {:scrivener_ecto, "~> 2.0"},

      # testing
      {:ex_machina, "~> 2.3"},
      {:excoveralls, "~> 0.10", only: :test},
      {:elixir_uuid, "~> 1.2"},
      {:timex, "~> 3.1"},

      # enumeration
      {:ecto_enum, "~> 1.2"},

      # worker pool
      {:poolboy, "~> 1.5"},

      # image uploading
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.0"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.6"},
      {:sweet_xml, "~> 0.6"},

      # slugger
      {:slugger, "~> 0.3"},

      # mailer
      {:bamboo, github: "thoughtbot/bamboo"},
      {:phoenix, "~> 1.4.10"},
      {:gettext, "~> 0.11"},
      {:phoenix_html, "~> 2.13.2"},

      # Phone Number Validation
      {:ex_phone_number, "~> 0.2"},

      # elasticsearch
      {:tirexs, "~> 0.8"},

      # csv parsing
      {:nimble_csv, "~> 0.7"},

      # MQTT
      {:tortoise, "~> 0.9"},

      # flow based programming
      {:virta, in_umbrella: true},

      # Elixir implementation of the generic tree data structure
      {:nary_tree, git: "https://github.com/BandanaPandey/nary_tree.git"},

      # redis
      {:redix, ">= 0.0.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      quality: ["format", "credo --strict", "sobelow --verbose", "dialyzer", "test"],
      "quality.ci": [
        "test",
        "format --check-formatted",
        "credo --strict",
        "sobelow --exit",
        "dialyzer --halt-exit-status"
      ]
    ]
  end
end
