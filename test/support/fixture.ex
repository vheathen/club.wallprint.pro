defmodule Club.Fixture do
  @moduledoc false
  import Club.Factory

  use Club.Fixtures.Brands
  use Club.Fixtures.SurfaceTypes
  use Club.Fixtures.Colors
  use Club.Fixtures.Accounts

  def meta(attrs \\ []) do
    build(:metadata, attrs)
  end

  def make_cmd(factory, module, attrs) do
    factory
    |> build(attrs)
    |> module.new()
    |> Ecto.Changeset.apply_changes()
  end
end
