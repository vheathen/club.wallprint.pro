defmodule Club.Colors.Commands.UpdateColorHexTest do
  use Club.CommandCase,
    command: Club.Colors.Commands.UpdateColorHex,
    factory: :update_color_hex

  alias Club.Colors.Commands.UpdateColorHex

  required_fields([
    :color_uuid,
    :hex
  ])

  fields(
    Ecto.UUID,
    [
      :color_uuid
    ]
  )

  basic_command_tests()

  describe "UpdateColorHex" do
    @describetag :unit

    test "incorrect color hex - invalid command" do
      ~w(
        fff
        fgfgfg
        just_a_string
      )
      |> Enum.each(fn hex ->
        color = build(:update_color_hex, %{hex: hex})

        %{errors: errors} = cmd = UpdateColorHex.new(color)
        refute cmd.valid?
        assert Enum.any?(errors, fn {field, {_, [validation: :format]}} -> field == :hex end)
      end)
    end
  end
end
