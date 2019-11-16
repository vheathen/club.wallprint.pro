defmodule Club.Fixtures.Brands do
  alias Club.Brands.Commands.{
    # AddBrand,
    # RenameBrand,
    # UpdateBrandUrl,
    LinkNewProductWithBrand,
    UnlinkProductFromBrand
  }

  # alias Club.Brands.Events.{
  #   BrandAdded,
  #   BrandRenamed,
  #   BrandUrlUpdated,
  #   NewProductWithBrandLinked,
  #   ProductFromBrandUnlinked
  # }

  defmacro __using__(_opts) do
    quote do
      def link_product_cmd(attrs) do
        :link_new_product_with_brand
        |> build(attrs)
        |> LinkNewProductWithBrand.new()
        |> Ecto.Changeset.apply_changes()
      end

      def unlink_product_cmd(attrs \\ []) do
        :unlink_product_from_brand
        |> build(attrs)
        |> UnlinkProductFromBrand.new()
        |> Ecto.Changeset.apply_changes()
      end
    end
  end
end
