defmodule Scribit.Repo do
  use Ecto.Repo,
    otp_app: :scribit,
    adapter: Ecto.Adapters.Postgres
end
