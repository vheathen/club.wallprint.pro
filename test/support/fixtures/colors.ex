defmodule Club.Fixtures.Colors do
  alias Club.Colors.Commands.{
    AddColor,
    RenameColor,
    UpdateColorHex,
    UseColor,
    StopUsingColor,
    DeleteColor
  }

  defmacro __using__(_opts) do
    quote do
      def color_agg(attrs \\ []), do: build(:color_aggregate, attrs)

      def add_color_cmd(attrs \\ []),
        do:
          make_cmd(
            :new_color,
            AddColor,
            attrs
          )

      def rename_color_cmd(attrs \\ []),
        do:
          make_cmd(
            :rename_color,
            RenameColor,
            attrs
          )

      def update_color_hex_cmd(attrs \\ []),
        do:
          make_cmd(
            :update_color_hex,
            UpdateColorHex,
            attrs
          )

      def use_color_cmd(attrs \\ []),
        do:
          make_cmd(
            :use_color,
            UseColor,
            attrs
          )

      def stop_using_color_cmd(attrs \\ []),
        do:
          make_cmd(
            :stop_using_color,
            StopUsingColor,
            attrs
          )

      def delete_color_cmd(attrs \\ []),
        do:
          make_cmd(
            :delete_color,
            DeleteColor,
            attrs
          )
    end
  end
end
