# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

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
  routes_backend: ScribitWeb.Pow.Routes

config :scribit, :pow_assent,
  providers: [
    google: [
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      strategy: Assent.Strategy.Google
    ],
    facebook: [
      client_id: System.get_env("FACEBOOK_CLIENT_ID"),
      client_secret: System.get_env("FACEBOOK_CLIENT_SECRET"),
      strategy: Assent.Strategy.Facebook
    ],
    vk: [
      client_id: System.get_env("VK_CLIENT_ID"),
      client_secret: System.get_env("VK_CLIENT_SECRET"),
      strategy: Assent.Strategy.VK
    ]

  ]

config :phoenix_inline_svg, dir: "/priv/static/images"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
