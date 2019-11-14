defmodule Club.Support.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      children(),
      strategy: :one_for_one
    )
  end

  def children,
    do: Club.Support.Unique.inject_child_spec([])
end
