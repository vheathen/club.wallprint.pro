defmodule Club.Accounts.Supervisor do
  use Supervisor

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Club.Accounts.Projectors.User
      ],
      strategy: :one_for_one
    )
  end
end
