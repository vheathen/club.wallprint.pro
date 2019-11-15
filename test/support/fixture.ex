defmodule Club.Fixture do
  @moduledoc false
  import Club.Factory

  def meta(attrs \\ []) do
    build(:metadata, attrs)
  end
end
