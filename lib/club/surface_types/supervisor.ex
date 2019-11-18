defmodule Club.SurfaceTypes.Supervisor do
  use Supervisor

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Club.SurfaceTypes.Projectors.SurfaceType,
        Club.SurfaceTypes.Projectors.UniquenessCache
      ],
      strategy: :one_for_one
    )
  end
end
