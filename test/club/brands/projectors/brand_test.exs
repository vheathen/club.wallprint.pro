defmodule Club.Brands.Projectors.BrandTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo

  alias Club.Brands

  alias Club.Brands.Projections.Brand, as: BrandProjection

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated
  }

  @topic "domain:brands"

  setup do
    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    brand = build(:new_brand)

    {:ok, _} = Brands.add_brand(brand, %{})

    wait_for_event(Club.Commanded, BrandAdded)

    [brand: brand]
  end

  describe "Brands.Projectors.Brand" do
    @describetag :integration

    test "BrandAdded event shoud insert a new brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      assert_receive {:brand_added, %{brand_uuid: ^brand_uuid}}, 1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert brand.brand_name == brand_projection.brand_name
      assert brand.brand_url == brand_projection.brand_url
      assert 0 == brand_projection.product_count
    end

    test "BrandRenamed event shoud update an existing brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      %{brand_name: brand_name} = rename_brand = build(:rename_brand, brand_uuid: brand_uuid)

      :ok = Brands.rename_brand(rename_brand, %{})

      wait_for_event(Club.Commanded, BrandRenamed)

      assert_receive {:brand_renamed, %{brand_uuid: ^brand_uuid, brand_name: ^brand_name}},
                     1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert rename_brand.brand_name == brand_projection.brand_name
      assert brand.brand_url == brand_projection.brand_url
      assert 0 == brand_projection.product_count
    end

    test "BrandUrlUpdated event shoud update an existing brand record", %{
      brand: %{brand_uuid: brand_uuid} = brand
    } do
      %{brand_url: brand_url} =
        update_brand_url = build(:update_brand_url, brand_uuid: brand_uuid)

      :ok = Brands.update_brand_url(update_brand_url, %{})

      wait_for_event(Club.Commanded, BrandUrlUpdated)

      assert_receive {:brand_url_updated, %{brand_uuid: ^brand_uuid, brand_url: ^brand_url}},
                     1_000

      result = Repo.all(BrandProjection)
      assert length(result) == 1
      [brand_projection] = result

      assert brand.brand_uuid == brand_projection.brand_uuid
      assert brand.brand_name == brand_projection.brand_name
      assert update_brand_url.brand_url == brand_projection.brand_url
      assert 0 == brand_projection.product_count
    end
  end
end
