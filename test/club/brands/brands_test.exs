defmodule Club.BrandsTest do
  use Club.DataCase

  alias Commanded.Aggregates.Aggregate

  alias Club.Commanded

  alias Club.Brands
  alias Club.Brands.Aggregates.Brand

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated
  }

  describe "add_brand/2" do
    @describetag :integration
    test "should succeed and return a new brand_uuid if parameters are correct but doesn't contain brand_uuid" do
      brand = :new_brand |> build() |> Map.delete(:brand_uuid)
      {:ok, brand_uuid} = Brands.add_brand(brand, %{})

      assert_receive_event(Club.Commanded, BrandAdded, fn event ->
        assert brand_uuid == event.brand_uuid
        assert brand.name == event.name
        assert brand.url == event.url
        assert brand.user_uuid == event.user_uuid
        assert brand.user_name == event.user_name
      end)

      assert Aggregate.aggregate_state(Commanded, Brand, "brand-" <> brand_uuid) ==
               %Brand{
                 uuid: brand_uuid,
                 name: brand.name,
                 url: brand.url,
                 product_count: 0
               }
    end

    test "should succeed and return provided brand_uuid if parameters are correct" do
      brand = :new_brand |> build()
      {:ok, brand_uuid} = Brands.add_brand(brand, %{})

      assert brand_uuid == brand.brand_uuid
    end

    test "should fail and return error if parameters are incorrect" do
      brand =
        :new_brand
        |> build()
        |> Map.delete(:brand_uuid)
        |> Map.delete(:name)

      {:error, {:validation_failure, %{name: _}}} = Brands.add_brand(brand, %{})
    end
  end

  describe "rename_brand/2" do
    @describetag :integration

    test "should succeed and return :ok if parameters are correct" do
      add_brand = :new_brand |> build()
      {:ok, brand_uuid} = Brands.add_brand(add_brand, %{})

      wait_for_event(Commanded, BrandAdded)

      rename_brand = build(:rename_brand, brand_uuid: brand_uuid)
      :ok = Brands.rename_brand(rename_brand, %{})

      assert_receive_event(Club.Commanded, BrandRenamed, fn event ->
        assert brand_uuid == event.brand_uuid
        assert rename_brand.name == event.name
        assert rename_brand.user_uuid == event.user_uuid
        assert rename_brand.user_name == event.user_name
      end)

      assert Aggregate.aggregate_state(Commanded, Brand, "brand-" <> brand_uuid) ==
               %Brand{
                 uuid: brand_uuid,
                 name: rename_brand.name,
                 url: add_brand.url,
                 product_count: 0
               }
    end

    test "should fail and return error if parameters are incorrect" do
      rename_brand =
        :rename_brand
        |> build()
        |> Map.delete(:brand_uuid)

      assert {:error, {:validation_failure, %{brand_uuid: ["can't be blank"]}}} ==
               Brands.rename_brand(rename_brand, %{})
    end

    test "should fail and return error if no brand with this id exists" do
      add_brand = build(:new_brand)
      {:ok, _brand_uuid} = Brands.add_brand(add_brand, %{})

      wait_for_event(Commanded, BrandAdded)

      rename_brand = build(:rename_brand)

      assert {:error, :brand_doesnt_exist} == Brands.rename_brand(rename_brand, %{})
    end
  end

  describe "update_url/2" do
    @describetag :integration

    test "should succeed and return :ok if parameters are correct" do
      add_brand = :new_brand |> build()
      {:ok, brand_uuid} = Brands.add_brand(add_brand, %{})

      wait_for_event(Commanded, BrandAdded)

      update_url = build(:update_url, brand_uuid: brand_uuid)
      :ok = Brands.update_url(update_url, %{})

      assert_receive_event(Club.Commanded, BrandUrlUpdated, fn event ->
        assert brand_uuid == event.brand_uuid
        assert update_url.url == event.url
        assert update_url.user_uuid == event.user_uuid
        assert update_url.user_name == event.user_name
      end)

      assert Aggregate.aggregate_state(Commanded, Brand, "brand-" <> brand_uuid) ==
               %Brand{
                 uuid: brand_uuid,
                 name: add_brand.name,
                 url: update_url.url,
                 product_count: 0
               }
    end

    test "should fail and return error if parameters are incorrect" do
      update_url =
        :update_url
        |> build()
        |> Map.delete(:brand_uuid)

      assert {:error, {:validation_failure, %{brand_uuid: ["can't be blank"]}}} ==
               Brands.update_url(update_url, %{})
    end

    test "should fail and return error if no brand with this id exists" do
      add_brand = build(:new_brand)
      {:ok, _brand_uuid} = Brands.add_brand(add_brand, %{})

      wait_for_event(Commanded, BrandAdded)

      update_url = build(:update_url)

      assert {:error, :brand_doesnt_exist} == Brands.update_url(update_url, %{})
    end
  end

  describe "brand_exists?/1" do
    @describetag :integration

    setup do
      Phoenix.PubSub.subscribe(Club.EventBus, "domain:brands")

      %{brand_uuid: brand_uuid} = brand = build(:new_brand)
      {:ok, _} = Brands.add_brand(brand, %{})

      assert_receive {:brand_added, %{brand_uuid: ^brand_uuid}}, 1_000

      [brand: brand]
    end

    test "should return true if there is no such brand", %{
      brand: %{name: existing_name}
    } do
      unique_name = unique_name(existing_name)

      assert Brands.brand_unique?(%{name: unique_name})
    end

    test "should return false if the brand exists", %{
      brand: brand
    } do
      refute Brands.brand_unique?(brand)
    end

    def unique_name(old_name) do
      name = Faker.Company.buzzword()

      case name != old_name do
        true -> name
        false -> unique_name(old_name)
      end
    end
  end
end
