defmodule Club.Fixtures.SurfaceTypes do
  alias Club.SurfaceTypes.Commands.{
    AddSurfaceTypeSupportToProduct,
    WithdrawSurfaceTypeSupportFromProduct
  }

  # alias Club.SurfaceTypes.Events.{
  # }

  defmacro __using__(_opts) do
    quote do
      def add_surface_type_support_cmd(attrs) do
        :add_surface_type_support_to_product
        |> build(attrs)
        |> AddSurfaceTypeSupportToProduct.new()
        |> Ecto.Changeset.apply_changes()
      end

      def withdraw_surface_type_support_cmd(attrs \\ []) do
        :withdraw_surface_type_support_from_product
        |> build(attrs)
        |> WithdrawSurfaceTypeSupportFromProduct.new()
        |> Ecto.Changeset.apply_changes()
      end
    end
  end
end
