# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :scribit,
  ecto_repos: [Scribit.Repo]

# Configures the endpoint
config :scribit, ScribitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0qYYIVeGcCDcruvNQdbSisY8LjnCgjF/JSXTZB+PWSUzynU8kB9dXwepOaFDZatd",
  render_errors: [view: ScribitWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Scribit.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "pXALvg8wor5rhz3+VQh8oKFDoXypYfRz"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :scribit, :pow,
  user: Scribit.Users.User,
  repo: Scribit.Repo,
  web_module: ScribitWeb,
  routes_backend: ScribitWeb.Pow.Routes,
  extensions: [PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  cache_store_backend: Pow.Store.Backend.MnesiaCache

config :phoenix_inline_svg, dir: "/priv/static/images"

if Mix.env() == :dev do
  config :mix_test_watch,
    tasks: [
      "test",
      "format",
      "credo --strict",
      "sobelow --verbose"
    ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
