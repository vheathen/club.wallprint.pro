defmodule Club.Support.ConfigTest do
  use ExUnit.Case, async: false

  alias Club.Support.Config

  test "Config.get must return correct values" do
    assert Config.get(:test) ==
             :club
             |> Application.get_all_env()
             |> Keyword.get(:test)
  end

  test "Config.get_sub must return correct values" do
    :club
    |> Application.get_env(:test)
    |> Enum.each(fn {subkey, sub_value} ->
      assert Config.get_sub(:test, subkey) == sub_value
    end)
  end
end
