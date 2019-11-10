defmodule Club.MixProject do
  use Mix.Project

  def project do
    [
      app: :club,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Club.Application, []},
      extra_applications: [:logger, :runtime_tools, :mnesia]
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
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1",},
      {:postgrex, ">= 0.0.0", override: true},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},

      #
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},

      # commanded and surrounding
      {:commanded, "~> 1.0.0-pre", override: true},
      {:eventstore, "~> 1.0.0-pre"},
      {:commanded_eventstore_adapter, "~> 1.0.0-pre"},
      {:commanded_ecto_projections, "~> 1.0.0-pre"},
      {:commanded_audit_middleware, github: "commanded/commanded-audit-middleware" }, #"~> 0.4"},
      # {:commanded_scheduler, github: "commanded/commanded-scheduler" }, # "~> 0.2"},

      # phoenix_inline_svg requires floki not only in :test env, only: :test},
      {:floki, ">= 0.0.0"},
      {:pow, "~> 1.0.14"},
      {:pow_assent, "~> 0.4.1"},

      # Optional, but recommended for SSL validation with :httpc adapter
      {:certifi, "~> 2.4"},
      {:ssl_verify_fun, "~> 1.1"},
      {:phoenix_inline_svg, "~> 1.3"},

      #
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "es.init": ["event_store.drop", "event_store.create", "event_store.init"],
      "read.init": ["ecto.drop", "ecto.create", "ecto.migrate", "run priv/read_repo/seeds.exs"],
      "audit.init": ["ecto.drop -r Commanded.Middleware.Auditing.Repo --force", "ecto.create -r Commanded.Middleware.Auditing.Repo", "ecto.migrate -r Commanded.Middleware.Auditing.Repo"],
      # "scheduler.init": ["ecto.drop --repo Commanded.Scheduler.Repo", "ecto.create --repo Commanded.Scheduler.Repo", "ecto.migrate --repo Commanded.Scheduler.Repo"],
      # "storage.init": ["audit.init", "read.init", "scheduler.init", "es.init"],
      "storage.init": ["audit.init", "read.init", "es.init"],
      # test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
