defmodule Club.ReadRepo do
  use Ecto.Repo,
    otp_app: :club,
    adapter: Ecto.Adapters.Postgres
end
