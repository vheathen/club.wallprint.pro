defmodule Club.Brands.Aggregates.BrandTest do
  use Club.AggregateCase,
    aggregate: Club.Brands.Aggregates.Brand

  # alias Club.Brands.Aggregates.Brand

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl
  }

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated
  }

  describe "AddBrand command" do
    @describetag :unit

    setup do
      add_brand = :new_brand |> build() |> AddBrand.new() |> Ecto.Changeset.apply_changes()

      [cmd: add_brand]
    end

    test "should return BrandAdded event for the first time", %{cmd: cmd} do
      brand_added = BrandAdded.new(cmd)
      assert_events(cmd, [brand_added])
    end

    test "should return {:error, :brand_already_exists} on the second try", %{cmd: cmd} do
      brand_added = BrandAdded.new(cmd)
      assert_error([brand_added], cmd, {:error, :brand_already_exists})
    end
  end

  describe "RenameBrand command" do
    @describetag :unit

    setup do
      add_brand =
        :new_brand
        |> build()
        |> AddBrand.new()
        |> Ecto.Changeset.apply_changes()

      rename_brand =
        :rename_brand
        |> build(brand_uuid: add_brand.brand_uuid)
        |> RenameBrand.new()
        |> Ecto.Changeset.apply_changes()

      [add_brand: add_brand, rename_brand: rename_brand]
    end

    test "should return BrandRenamed event for the existing brand", %{
      add_brand: add_brand,
      rename_brand: rename_brand
    } do
      brand_added = BrandAdded.new(add_brand)
      brand_renamed = BrandRenamed.new(rename_brand)
      assert_events([brand_added], rename_brand, [brand_renamed])
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

    setup do
      add_brand =
        :new_brand
        |> build()
        |> AddBrand.new()
        |> Ecto.Changeset.apply_changes()

      update_url =
        :update_url
        |> build(brand_uuid: add_brand.brand_uuid)
        |> UpdateBrandUrl.new()
        |> Ecto.Changeset.apply_changes()

      [add_brand: add_brand, update_url: update_url]
    end

    test "should return BrandUrlChanged event for the existing brand", %{
      add_brand: add_brand,
      update_url: update_url
    } do
      brand_added = BrandAdded.new(add_brand)
      url_updated = BrandUrlUpdated.new(update_url)
      assert_events([brand_added], update_url, [url_updated])
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
end
