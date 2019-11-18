defmodule Club.Brands.Projectors.UniquenessCacheTest do
  use Club.DataCase

  require Cachex.Spec

  alias Club.Brands

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
    on_exit(fn ->
      Cachex.clear(@cachex_adapter)
    end)

    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    brand = build(:new_brand)
    {:ok, uuid} = Brands.add_brand(brand, meta())

    assert_receive {:brand_added, %{brand_uuid: ^uuid}}, 1_000

    [brand: brand]
  end

  describe "uniqueness cache records should be released" do
    @describetag :integration

    test "on brand_deleted event", %{brand: %{brand_uuid: old_uuid, name: old_name} = old_brand} do
      new_brand = build(:new_brand, name: old_name)

      delete_brand = build(:delete_brand, brand_uuid: old_brand.brand_uuid)

      assert {:error, :validation_failure, [brand: "has already exist"]} ==
               Brands.add_brand(new_brand, meta())

      :ok = Brands.delete_brand(delete_brand, meta())

      assert_receive {:brand_deleted, %{brand_uuid: ^old_uuid}}, 1_000

      Process.sleep(1_000)

      assert {:ok, _} = Brands.add_brand(new_brand, meta())
    end
  end
end
