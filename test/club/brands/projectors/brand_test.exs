defmodule Club.Brands.Projectors.BrandTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo

  alias Club.Brands

  alias Club.Brands.Projections.Brand, as: BrandProjection

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated,
    NewProductWithBrandLinked,
    ProductFromBrandUnlinked
  }

  @topic "domain:brands"

  setup do
    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    brand = build(:new_brand)

    {:ok, _} = Brands.add_brand(brand, meta())

    wait_for_event(Club.Commanded, BrandAdded)

    [brand: brand]
  end

  describe "Brands.Projectors.Brand on" do
    @describetag :integration

    test "BrandAdded event shoud insert a new brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      assert_receive {:brand_added, %{brand_uuid: ^brand_uuid}}, 1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert brand.name == brand_projection.name
      assert brand.url == brand_projection.url
      assert 0 == brand_projection.product_count
    end

    test "BrandRenamed event shoud update an existing brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      %{name: name} = rename_brand = build(:rename_brand, brand_uuid: brand_uuid)

      :ok = Brands.rename_brand(rename_brand, meta())

      wait_for_event(Club.Commanded, BrandRenamed)

      assert_receive {:brand_renamed, %{brand_uuid: ^brand_uuid, name: ^name}},
                     1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert rename_brand.name == brand_projection.name
      assert brand.url == brand_projection.url
      assert 0 == brand_projection.product_count
    end

    test "BrandUrlUpdated event shoud update an existing brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      %{url: url} = update_url = build(:update_url, brand_uuid: brand_uuid)

      :ok = Brands.update_url(update_url, meta())

      wait_for_event(Club.Commanded, BrandUrlUpdated)

      assert_receive {:url_updated, %{brand_uuid: ^brand_uuid, url: ^url}},
                     1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert brand.name == brand_projection.name
      assert update_url.url == brand_projection.url
      assert 0 == brand_projection.product_count
    end

    test "LinkNewProductWithBrand event shoud increment product_count of the brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      link_product = link_product_cmd(brand_uuid: brand_uuid)

      :ok = Club.Commanded.dispatch(link_product, metadata: meta())

      wait_for_event(Club.Commanded, NewProductWithBrandLinked)

      assert_receive {:product_linked, %{brand_uuid: ^brand_uuid}},
                     1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert brand.name == brand_projection.name
      assert brand.url == brand_projection.url
      assert 1 == brand_projection.product_count
    end

    test "UnlinkProductFromBrand event shoud decrement product_count of the brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      link_product1 = link_product_cmd(brand_uuid: brand_uuid)
      link_product2 = link_product_cmd(brand_uuid: brand_uuid)

      :ok = Club.Commanded.dispatch(link_product1, metadata: meta())
      wait_for_event(Club.Commanded, NewProductWithBrandLinked)

      assert_receive {:product_linked, %{brand_uuid: ^brand_uuid}},
                     1_000

      :ok = Club.Commanded.dispatch(link_product2, metadata: meta())
      wait_for_event(Club.Commanded, NewProductWithBrandLinked)

      assert_receive {:product_linked, %{brand_uuid: ^brand_uuid}},
                     1_000

      unlink_product =
        unlink_product_cmd(brand_uuid: brand_uuid, product_uuid: link_product1.product_uuid)

      :ok = Club.Commanded.dispatch(unlink_product, metadata: meta())
      wait_for_event(Club.Commanded, ProductFromBrandUnlinked)

      assert_receive {:product_unlinked, %{brand_uuid: ^brand_uuid}},
                     1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert brand.name == brand_projection.name
      assert brand.url == brand_projection.url
      assert 1 == brand_projection.product_count
    end

    test "BrandDeleted event shoud delete an old brand record", %{
      brand: %{brand_uuid: brand_uuid}
    } do
      assert_receive {:brand_added, %{brand_uuid: ^brand_uuid}}, 1_000

      assert [_] = Repo.all(BrandProjection)

      delete_brand = delete_brand_cmd(brand_uuid: brand_uuid)
      :ok = Club.Commanded.dispatch(delete_brand, metadata: meta())

      assert_receive {:brand_deleted, %{brand_uuid: ^brand_uuid}}, 1_000

      assert [] = Repo.all(BrandProjection)
    end
  end
end
