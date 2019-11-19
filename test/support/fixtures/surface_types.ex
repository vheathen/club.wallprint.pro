defmodule Club.Fixtures.SurfaceTypes do
  alias Club.SurfaceTypes.Commands.{
    AddSurfaceTypeSupportToProduct,
    WithdrawSurfaceTypeSupportFromProduct,
    DeleteSurfaceType
  }

  # alias Club.SurfaceTypes.Events.{
  # }

  defmacro __using__(_opts) do
    quote do
      def add_surface_type_support_cmd(attrs \\ []),
        do:
          make_cmd(
            :add_surface_type_support_to_product,
            AddSurfaceTypeSupportToProduct,
            attrs
          )

      def withdraw_surface_type_support_cmd(attrs \\ []),
        do:
          make_cmd(
            :withdraw_surface_type_support_from_product,
            WithdrawSurfaceTypeSupportFromProduct,
            attrs
          )

      def delete_surface_type_cmd(attrs \\ []),
        do:
          make_cmd(
            :delete_surface_type,
            DeleteSurfaceType,
            attrs
          )
    end
  end
end
