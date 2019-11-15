defmodule Club.Brands.Commands.UniqueBrandNameTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo
  require Cachex.Spec

  alias Club.Brands
  alias Club.Brands.Projections.Brand, as: BrandProjection

  @uniqueness_key Club.Support.Unique
  @cachex_adapter Module.concat(@uniqueness_key, Cachex)

  @topic "domain:brands"

  setup_all do
    case Cachex.get(@cachex_adapter, :anything) do
      {:error, :no_cache} ->
        Application.put_env(:club, @uniqueness_key, adapter: @cachex_adapter)

        {:ok, _} =
          Cachex.start_link(@cachex_adapter, expiration: Cachex.Spec.expiration(default: 100))

      {:ok, _} ->
        true
    end

    :ok
  end

  setup do
    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    %{brand_uuid: uuid} = brand = new_brand()
    {:ok, _} = Brands.add_brand(brand, meta())

    assert_receive {:brand_added, %{brand_uuid: ^uuid}}, 1_000

    [brand: brand]
  end

  describe "AddBrand" do
    @describetag :integration

    test "with unique name should succeed" do
      %{brand_uuid: uuid} = brand = new_brand()
      {:ok, _} = Brands.add_brand(brand, meta())
      assert_receive {:brand_added, %{brand_uuid: ^uuid}}, 1_000
      assert length(Repo.all(BrandProjection)) == 2
    end

    test "with duplicate name should fail based on the cached results", %{brand: brand} do
      uuid = UUID.uuid4()
      brand = %{brand | brand_uuid: uuid}
      Repo.delete_all(BrandProjection)
      result = Brands.add_brand(brand, meta())
      assert result == {:error, :validation_failure, [brand: "has already exist"]}
    end

    test "with duplicate name should fail based on the readstore results", %{brand: brand} do
      uuid = UUID.uuid4()
      brand = %{brand | brand_uuid: uuid}
      Cachex.clear(@cachex_adapter)
      result = Brands.add_brand(brand, meta())
      assert result == {:error, :validation_failure, [brand: "has already exist"]}
    end
  end

  describe "RenameBrand" do
    @describetag :integration

    test "with unique name should succeed", %{brand: %{brand_uuid: brand_uuid}} do
      rename_brand = rename_brand(%{brand_uuid: brand_uuid})
      :ok = Brands.rename_brand(rename_brand, meta())
      assert_receive {:brand_renamed, %{brand_uuid: ^brand_uuid}}, 1_000
      assert length(Repo.all(BrandProjection)) == 1
    end

    test "with duplicate name should fail based on the cached results", %{brand: brand} do
      %{brand_uuid: new_uuid} = new_brand = new_brand()
      {:ok, _} = Brands.add_brand(new_brand, meta())

      assert_receive {:brand_added, %{brand_uuid: ^new_uuid}}, 1_000
      assert length(Repo.all(BrandProjection)) == 2

      Repo.delete_all(BrandProjection)

      rename_brand = rename_brand(%{brand_uuid: new_uuid, name: brand.name})
      result = Brands.rename_brand(rename_brand, meta())
      assert result == {:error, :validation_failure, [brand: "has already exist"]}
    end

    test "with duplicate name should fail based on the readstore results", %{brand: brand} do
      %{brand_uuid: new_uuid} = new_brand = new_brand()
      {:ok, _} = Brands.add_brand(new_brand, meta())

      assert_receive {:brand_added, %{brand_uuid: ^new_uuid}}, 1_000
      assert length(Repo.all(BrandProjection)) == 2

      Cachex.clear(@cachex_adapter)

      rename_brand = rename_brand(%{brand_uuid: new_uuid, name: brand.name})
      result = Brands.rename_brand(rename_brand, meta())
      assert result == {:error, :validation_failure, [brand: "has already exist"]}
    end
  end

  defp new_brand(attrs \\ []) do
    build(:new_brand, attrs)
  end

  defp rename_brand(attrs) do
    build(:rename_brand, attrs)
  end
end
