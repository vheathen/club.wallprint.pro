defmodule Club.Brands.Aggregates.BrandTest do
  use Club.AggregateCase,
    aggregate: Club.Brands.Aggregates.Brand

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl
  }

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated,
    NewProductWithBrandLinked,
    ProductFromBrandUnlinked,
    BrandDeleted
  }

  setup do
    add_brand = :new_brand |> build() |> AddBrand.new() |> Ecto.Changeset.apply_changes()

    brand_aggregate =
      build(:brand_aggregate, %{
        uuid: add_brand.brand_uuid,
        name: add_brand.name,
        url: add_brand.url
      })

    [add_brand: add_brand, brand: brand_aggregate]
  end

  describe "AddBrand command" do
    @describetag :unit

    test "should return BrandAdded event for the first time", %{add_brand: cmd, brand: brand} do
      brand_added = BrandAdded.new(cmd)
      assert_events(cmd, [brand_added])
      assert_state(cmd, brand)
    end

    test "should return {:error, :brand_already_exists} on the second try", %{add_brand: cmd} do
      brand_added = BrandAdded.new(cmd)
      assert_error([brand_added], cmd, {:error, :brand_already_exists})
    end
  end

  describe "RenameBrand command" do
    @describetag :unit

    setup %{add_brand: add_brand, brand: brand} do
      rename_brand =
        :rename_brand
        |> build(brand_uuid: add_brand.brand_uuid)
        |> RenameBrand.new()
        |> Ecto.Changeset.apply_changes()

      brand = %{brand | name: rename_brand.name}

      [add_brand: add_brand, rename_brand: rename_brand, brand: brand]
    end

    test "should return BrandRenamed event for the existing brand", %{
      add_brand: add_brand,
      rename_brand: rename_brand,
      brand: brand
    } do
      brand_added = BrandAdded.new(add_brand)
      brand_renamed = BrandRenamed.new(rename_brand)
      assert_events([brand_added], rename_brand, [brand_renamed])
      assert_state([brand_added], rename_brand, brand)
    end

    test "should return {:error, :brand_doesnt_exist} if no such brand exists", %{
      rename_brand: rename_brand
    } do
      assert_error(rename_brand, {:error, :brand_doesnt_exist})
    end

    test "should not return any events if name is the same as previous one", %{
      add_brand: add_brand,
      rename_brand: rename_brand
    } do
      brand_added = BrandAdded.new(add_brand)
      rename_brand = %{rename_brand | name: brand_added.name}
      assert_events([brand_added], rename_brand, [])
    end
  end

  describe "UpdateBrandUrl command" do
    @describetag :unit

    setup %{add_brand: add_brand, brand: brand} do
      update_url =
        :update_url
        |> build(brand_uuid: add_brand.brand_uuid)
        |> UpdateBrandUrl.new()
        |> Ecto.Changeset.apply_changes()

      brand = %{brand | url: update_url.url}

      [add_brand: add_brand, update_url: update_url, brand: brand]
    end

    test "should return BrandUrlChanged event for the existing brand", %{
      add_brand: add_brand,
      update_url: update_url,
      brand: brand
    } do
      brand_added = BrandAdded.new(add_brand)
      url_updated = BrandUrlUpdated.new(update_url)
      assert_events([brand_added], update_url, [url_updated])
      assert_state([brand_added], update_url, brand)
    end

    test "should return {:error, :brand_doesnt_exist} if no such brand exists", %{
      update_url: update_url
    } do
      assert_error(update_url, {:error, :brand_doesnt_exist})
    end

    test "should not return any events if url is the same as previous one", %{
      add_brand: add_brand,
      update_url: update_url
    } do
      brand_added = BrandAdded.new(add_brand)
      update_url = %{update_url | url: brand_added.url}
      assert_events([brand_added], update_url, [])
    end
  end

  describe "LinkNewProductWithBrand command" do
    @describetag :unit

    setup %{add_brand: add_brand} do
      link_product = link_product_cmd(brand_uuid: add_brand.brand_uuid)

      [add_brand: add_brand, link_product: link_product]
    end

    test "should return NewProductWithBrandLinked event for the existing brand and unseen product_uuid",
         %{
           add_brand: add_brand,
           link_product: link_product1,
           brand: brand
         } do
      brand_added = BrandAdded.new(add_brand)

      product1_linked = NewProductWithBrandLinked.new(link_product1)
      brand1 = %{brand | product_count: 1, products: [link_product1.product_uuid]}

      assert_events([brand_added], link_product1, [product1_linked])
      assert_state([brand_added], link_product1, brand1)

      link_product2 = link_product_cmd(brand_uuid: add_brand.brand_uuid)
      product2_linked = NewProductWithBrandLinked.new(link_product2)

      brand2 = %{
        brand
        | product_count: 2,
          products: [link_product2.product_uuid, link_product1.product_uuid]
      }

      assert_events([brand_added, product1_linked], link_product2, [product2_linked])
      assert_state([brand_added, product1_linked], link_product2, brand2)
    end

    test "should return {:error, :brand_doesnt_exist} if no such brand exists", %{
      link_product: link_product
    } do
      assert_error(link_product, {:error, :brand_doesnt_exist})
    end

    test "should not return any events if product_uuid has already been linked", %{
      add_brand: add_brand,
      link_product: link_product
    } do
      brand_added = BrandAdded.new(add_brand)
      product_linked = NewProductWithBrandLinked.new(link_product)
      assert_events([brand_added, product_linked], link_product, [])
    end
  end

  describe "UnlinkProductFromBrand command" do
    @describetag :unit

    setup %{add_brand: add_brand, brand: brand} do
      brand_added = BrandAdded.new(add_brand)

      link_product1 = link_product_cmd(brand_uuid: add_brand.brand_uuid)
      product1_linked = NewProductWithBrandLinked.new(link_product1)

      link_product2 = link_product_cmd(brand_uuid: add_brand.brand_uuid)
      product2_linked = NewProductWithBrandLinked.new(link_product2)

      brand2 = %{
        brand
        | product_count: 2,
          products: [link_product2.product_uuid, link_product1.product_uuid]
      }

      [
        start_events: [brand_added, product1_linked, product2_linked],
        start_state: brand2,
        p1: product1_linked,
        p2: product2_linked
      ]
    end

    test "should return NewProductWithBrandLinked event for the existing brand and unseen product_uuid",
         %{
           start_events: start_events,
           start_state: %{uuid: brand_uuid} = start_state,
           p1: %{product_uuid: p1uuid},
           p2: %{product_uuid: p2uuid}
         } do
      unlink_product1 = unlink_product_cmd(brand_uuid: brand_uuid, product_uuid: p1uuid)
      product1_unlinked = ProductFromBrandUnlinked.new(unlink_product1)

      assert_events(start_events, unlink_product1, [product1_unlinked])

      assert_state(start_events, unlink_product1, %{
        start_state
        | product_count: 1,
          products: start_state.products -- [p1uuid]
      })

      unlink_product2 = unlink_product_cmd(brand_uuid: brand_uuid, product_uuid: p2uuid)
      product2_unlinked = ProductFromBrandUnlinked.new(unlink_product2)

      assert_events(start_events ++ [product1_unlinked], unlink_product2, [product2_unlinked])

      assert_state(start_events ++ [product1_unlinked], unlink_product2, %{
        start_state
        | product_count: 0,
          products: []
      })
    end

    test "should return {:error, :brand_doesnt_exist} if no such brand exists" do
      unlink_product = unlink_product_cmd()
      assert_error(unlink_product, {:error, :brand_doesnt_exist})
    end

    test "should not return any events if product_uuid has not been linked", %{
      start_events: start_events,
      start_state: %{uuid: brand_uuid}
    } do
      unlink_product = unlink_product_cmd(brand_uuid: brand_uuid)
      assert_events(start_events, unlink_product, [])
    end
  end

  describe "DeleteBrand command" do
    @describetag :unit

    setup %{add_brand: add_brand, brand: brand} do
      brand_added = BrandAdded.new(add_brand)

      link_product1 = link_product_cmd(brand_uuid: add_brand.brand_uuid)
      product1_linked = NewProductWithBrandLinked.new(link_product1)

      unlink_product1 =
        unlink_product_cmd(
          brand_uuid: add_brand.brand_uuid,
          product_uuid: link_product1.product_uuid
        )

      product1_unlinked = ProductFromBrandUnlinked.new(unlink_product1)

      start_state = %{
        brand
        | product_count: 1,
          products: [link_product1.product_uuid]
      }

      delete_brand = delete_brand_cmd(brand_uuid: start_state.uuid)
      brand_deleted = BrandDeleted.new(delete_brand)

      [
        start_events: [brand_added, product1_linked],
        start_state: start_state,
        product_unlinked: product1_unlinked,
        delete_brand: delete_brand,
        brand_deleted: brand_deleted
      ]
    end

    test "should return BrandDeleted event for the existing brand and product_count = 0",
         %{
           start_events: start_events,
           start_state: start_state,
           product_unlinked: product1_unlinked,
           delete_brand: delete_brand,
           brand_deleted: brand_deleted
         } do
      assert_events(start_events ++ [product1_unlinked], delete_brand, [brand_deleted])

      assert_state(start_events ++ [product1_unlinked], delete_brand, %{
        start_state
        | product_count: 0,
          products: [],
          deleted?: true
      })
    end

    test "should return {:error, :brand_doesnt_exist} if no such brand exists" do
      delete_brand = delete_brand_cmd()
      assert_error(delete_brand, {:error, :brand_doesnt_exist})
    end

    test "should return {:error, :brand_has_linked_products} if brand has linked products", %{
      start_events: start_events,
      delete_brand: delete_brand
    } do
      assert_error(start_events, delete_brand, {:error, :brand_has_linked_products})
    end

    test "should not return any events if brand already deleted", %{
      start_events: start_events,
      product_unlinked: product1_unlinked,
      delete_brand: delete_brand,
      brand_deleted: brand_deleted
    } do
      assert_events(start_events ++ [product1_unlinked, brand_deleted], delete_brand, [])
    end
  end
end
