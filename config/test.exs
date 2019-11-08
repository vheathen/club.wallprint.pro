import Config

# Configure your database
config :scribit, Scribit.Repo,
  username: "postgres",
  password: "postgres",
  database: "scribit_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :scribit, ScribitWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :scribit, :pow,
  user: Scribit.Users.User,
  repo: Scribit.Repo,
  web_module: ScribitWeb,
  routes_backend: ScribitWeb.Pow.Routes,
  extensions: [PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  cache_store_backend: Pow.Store.Backend.EtsCache

if !File.exists?("config/pow_assent.exs"),
  do:
    raise("""
      Pow Assent requires external auth providers settings!
      Please create config/pow_assent_social.exs file.
    """)

import_config("pow_assent.exs")
