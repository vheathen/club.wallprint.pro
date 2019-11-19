defmodule Club.Fixtures.Brands do
  alias Club.Brands.Commands.{
    # AddBrand,
    # RenameBrand,
    # UpdateBrandUrl,
    LinkNewProductWithBrand,
    UnlinkProductFromBrand,
    DeleteBrand
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
      def link_product_cmd(attrs),
        do:
          make_cmd(
            :link_new_product_with_brand,
            LinkNewProductWithBrand,
            attrs
          )

      def unlink_product_cmd(attrs \\ []),
        do:
          make_cmd(
            :unlink_product_from_brand,
            UnlinkProductFromBrand,
            attrs
          )

      def delete_brand_cmd(attrs \\ []),
        do:
          make_cmd(
            :delete_brand,
            DeleteBrand,
            attrs
          )
    end
  end
end
