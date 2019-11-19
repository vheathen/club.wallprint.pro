defmodule Club.Colors.Commands.AddColorTest do
  use Club.CommandCase,
    command: Club.Colors.Commands.AddColor,
    factory: :new_color

  alias Club.Colors.Commands.AddColor

  required_fields([
    :color_uuid,
    :name,
    :hex
  ])

  fields(
    :string,
    [
      :name,
      :hex
    ]
  )

  fields(
    Ecto.UUID,
    [
      :color_uuid
    ]
  )

  basic_command_tests()

  describe "AddColor" do
    @describetag :unit

    test "incorrect color hex - invalid command" do
      ~w(
        fff
        fgfgfg
        just_a_string
      )
      |> Enum.each(fn hex ->
        color = build(:new_color, %{hex: hex})

        %{errors: errors} = cmd = AddColor.new(color)
        refute cmd.valid?
        assert Enum.any?(errors, fn {field, {_, [validation: :format]}} -> field == :hex end)
      end)
    end
  end
end
