defmodule Club.Fixture do
  @moduledoc false
  import Club.Factory

  use Club.Fixtures.Brands

  def meta(attrs \\ []) do
    build(:metadata, attrs)
  end
end
