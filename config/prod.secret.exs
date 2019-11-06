# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :scribit, Scribit.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

live_view_signing_salt =
  System.get_env("LIVE_VIEW_SIGNING_SALT") ||
    raise """
    environment variable LIVE_VIEW_SIGNING_SALT is missing.
    You can generate one by calling: mix phx.gen.secret 32
    """

config :scribit, ScribitWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base,
  live_view: [
    signing_salt: live_view_signing_salt
  ]

# Pow Assent
google_client_id = System.get_env("GOOGLE_CLIENT_ID") || raise "no GOOGLE_CLIENT_ID env var!"
google_client_secret = System.get_env("GOOGLE_CLIENT_SECRET") || raise "no GOOGLE_CLIENT_ID env var!"

facebook_client_id = System.get_env("FACEBOOK_CLIENT_ID") || raise "no FACEBOOK_CLIENT_ID env var!"
facebook_client_secret = System.get_env("FACEBOOK_CLIENT_SECRET") || raise "no FACEBOOK_CLIENT_ID env var!"

vk_client_id = System.get_env("VK_CLIENT_ID") || raise "no VK_CLIENT_ID env var!"
vk_client_secret = System.get_env("VK_CLIENT_SECRET") || raise "no VK_CLIENT_ID env var!"

config :scribit, :pow_assent,
  providers: [
    google: [
      client_id: google_client_id,
      client_secret: google_client_secret,
      strategy: Assent.Strategy.Google
    ],
    facebook: [
      client_id: facebook_client_id,
      client_secret: facebook_client_secret,
      strategy: Assent.Strategy.Facebook
    ],
    vk: [
      client_id: vk_client_id,
      client_secret: vk_client_secret,
      strategy: Assent.Strategy.VK
    ]

  ]

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :scribit, ScribitWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
