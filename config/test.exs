import Config

# Configure your database
config :club, Club.ReadRepo,
  username: "postgres",
  password: "postgres",
  database: "club_read_test",
  hostname: "localhost"

# pool: Ecto.Adapters.SQL.Sandbox

# EventStore
config :club, Club.EventStore,
  username: "postgres",
  # password: "postgres",
  database: "club_es_test",
  hostname: "localhost",
  pool_size: 10

config :commanded_audit_middleware, Commanded.Middleware.Auditing.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "club_audit_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

# Scheduler repo
# config :commanded_scheduler, Commanded.Scheduler.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   database: "club_scheduler_test",
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   pool_size: 1

config :club, Club.Commanded,
  event_store: [
    adapter: Commanded.EventStore.Adapters.InMemory,
    serializer: Club.Support.JsonbSerializer
  ]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :club, ClubWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :club, :pow,
  user: Club.Users.User,
  repo: Club.ReadRepo,
  web_module: ClubWeb,
  routes_backend: ClubWeb.Pow.Routes,
  extensions: [PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  cache_store_backend: Pow.Store.Backend.EtsCache

if !File.exists?("config/pow_assent.exs"),
  do:
    raise("""
      Pow Assent requires external auth providers settings!
      Please create config/pow_assent_social.exs file.
    """)

config :club, :test,
  test_key1: :test_value1,
  test_key2: 42,
  test_key3: ["Forty two"]

import_config("pow_assent.exs")
