defmodule Club.Fixture do
  @moduledoc false
  import Club.Factory

  use Club.Fixtures.Brands
  use Club.Fixtures.SurfaceTypes

  def meta(attrs \\ []) do
    build(:metadata, attrs)
  end
end
