defmodule Club.Colors.Supervisor do
  use Supervisor

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Club.Colors.Projectors.Color
      ],
      strategy: :one_for_one
    )
  end
end
