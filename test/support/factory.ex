defmodule Club.Factory do
  use ExMachina.Ecto, repo: Club.ReadRepo

  # Brands domain
  use Club.Factories.Brands
  use Club.Factories.Devices
end
