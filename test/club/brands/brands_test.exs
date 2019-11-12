defmodule Club.BrandsTest do
  use Club.DataCase

  alias Commanded.Aggregates.Aggregate

  alias Club.Commanded

  alias Club.Brands
  alias Club.Brands.Aggregates.Brand

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed
  }

  describe "AddBrand/2" do
    @tag :integration
    test "should succeed and return a new brand_uuid if parameters are correct but doesn't contain brand_uuid" do
      brand = :new_brand |> build() |> Map.delete(:brand_uuid)
      {:ok, brand_uuid} = Brands.add_brand(brand, %{})

      assert_receive_event(Club.Commanded, BrandAdded, fn event ->
        assert brand_uuid == event.brand_uuid
        assert brand.brand_name == event.brand_name
        assert brand.brand_url == event.brand_url
        assert brand.user_uuid == event.user_uuid
        assert brand.user_name == event.user_name
      end)

      assert Aggregate.aggregate_state(Commanded, Brand, "brand-" <> brand_uuid) ==
               %Brand{
                 uuid: brand_uuid,
                 brand_name: brand.brand_name,
                 brand_url: brand.brand_url,
                 product_count: 0
               }
    end

    @tag :integration
    test "should succeed and return provided brand_uuid if parameters are correct" do
      brand = :new_brand |> build()
      {:ok, brand_uuid} = Brands.add_brand(brand, %{})

      assert brand_uuid == brand.brand_uuid
    end

    @tag :integration
    test "should fail and return error if parameters are incorrect" do
      brand =
        :new_brand
        |> build()
        |> Map.delete(:brand_uuid)
        |> Map.delete(:brand_name)

      {:error, {:validation_failure, %{brand_name: _}}} = Brands.add_brand(brand, %{})
    end
  end

  describe "RenameBrand/2" do
    @tag :integration
    test "should succeed and return :ok if parameters are correct" do
      add_brand = :new_brand |> build()
      {:ok, brand_uuid} = Brands.add_brand(add_brand, %{})

      wait_for_event(Commanded, BrandAdded)

      rename_brand = build(:rename_brand, brand_uuid: brand_uuid)
      :ok = Brands.rename_brand(rename_brand, %{})

      assert_receive_event(Club.Commanded, BrandRenamed, fn event ->
        assert brand_uuid == event.brand_uuid
        assert rename_brand.brand_new_name == event.brand_new_name
        assert rename_brand.user_uuid == event.user_uuid
        assert rename_brand.user_name == event.user_name
      end)

      assert Aggregate.aggregate_state(Commanded, Brand, "brand-" <> brand_uuid) ==
               %Brand{
                 uuid: brand_uuid,
                 brand_name: rename_brand.brand_new_name,
                 brand_url: add_brand.brand_url,
                 product_count: 0
               }
    end

    @tag :integration
    test "should fail and return error if parameters are incorrect" do
      rename_brand =
        :rename_brand
        |> build()
        |> Map.delete(:brand_uuid)

      assert {:error, {:validation_failure, %{brand_uuid: ["can't be blank"]}}} ==
               Brands.rename_brand(rename_brand, %{})
    end

    @tag :integration
    test "should fail and return error if no brand with this id exists" do
      add_brand = build(:new_brand)
      {:ok, _brand_uuid} = Brands.add_brand(add_brand, %{})

      wait_for_event(Commanded, BrandAdded)

      rename_brand = build(:rename_brand)

      assert {:error, :brand_doesnt_exist} == Brands.rename_brand(rename_brand, %{})
    end
  end
end
