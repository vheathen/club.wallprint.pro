# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :club,
  namespace: Club,
  ecto_repos: [Club.ReadRepo],
  generators: [binary_id: true],
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :club, ClubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0qYYIVeGcCDcruvNQdbSisY8LjnCgjF/JSXTZB+PWSUzynU8kB9dXwepOaFDZatd",
  render_errors: [view: ClubWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Club.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "pXALvg8wor5rhz3+VQh8oKFDoXypYfRz"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :club, :pow,
  user: Club.Users.User,
  repo: Club.ReadRepo,
  web_module: ClubWeb,
  routes_backend: ClubWeb.Pow.Routes,
  extensions: [PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  cache_store_backend: Pow.Store.Backend.MnesiaCache

config :phoenix_inline_svg, dir: "/priv/static/images"

config :club, event_stores: [Club.EventStore]

config :club, Club.EventStore,
  serializer: Club.Support.JsonbSerializer,
  column_data_type: "jsonb",
  types: EventStore.PostgresTypes

config :club, Club.Commanded,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: Club.EventStore
  ],
  pubsub: :local,
  registry: :local

config :commanded_audit_middleware,
  ecto_repos: [Commanded.Middleware.Auditing.Repo],
  serializer: Club.Support.JsonbSerializer,
  data_column_schema_type: :map,
  metadata_column_schema_type: :map,
  data_column_db_type: :jsonb,
  metadata_column_db_type: :jsonb

config :club, Club.Support.Unique,
  adapter: Club.Support.Unique.Cachex,
  # ttl: 60 minutes in milliseconds
  ttl: 60 * 60 * 1_000

config :commanded_uniqueness_middleware,
  adapter: Commanded.Middleware.Uniqueness.Adapter.Cachex,
  ttl: 60 * 60 * 1_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
