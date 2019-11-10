defmodule Club.EventStore do
  use EventStore, otp_app: :club

  # Optional `init/1` function to modify config at runtime.
  def init(config) do
    {:ok, config}
  end
end
