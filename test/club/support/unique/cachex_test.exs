defmodule Club.Support.Unique.CachexTest do
  use ExUnit.Case

  require Cachex.Spec

  @uniqueness_key Club.Support.Unique
  @cachex_adapter Module.concat(@uniqueness_key, Cachex)

  @by_value_key :bv
  @by_owner_key :bo

  setup_all do
    unique_settings = Application.get_env(:club, @uniqueness_key)

    case Cachex.get(@cachex_adapter, :anything) do
      {:error, :no_cache} ->
        Application.put_env(:club, @uniqueness_key, adapter: @cachex_adapter, ttl: 1_000)

        {:ok, _} =
          Cachex.start_link(@cachex_adapter, expiration: Cachex.Spec.expiration(default: 1_000))

      {:ok, _} ->
        Application.put_env(:club, @uniqueness_key, ttl: 1_000)
    end

    on_exit(fn ->
      Application.put_env(:club, @uniqueness_key, unique_settings)
    end)

    :ok
  end

  setup do
    on_exit(fn ->
      Cachex.clear(@cachex_adapter)
    end)

    id = :field_name
    value = Faker.Lorem.sentence()
    owner = UUID.uuid4()

    assert :ok == @cachex_adapter.claim(id, value, owner)

    [id: id, value: value, owner: owner]
  end

  describe "child_spec/0" do
    test "should return a correct child spec" do
      assert @cachex_adapter.child_spec ==
               %{
                 id: @cachex_adapter,
                 start:
                   {Cachex, :start,
                    [@cachex_adapter, [expiration: Cachex.Spec.expiration(default: 1_000)]]}
               }
    end
  end

  describe "claim/3" do
    test "should return :ok and put into cache owner under {@by_value_key, id, value} key and value under {@by_owner_key, id, owner} key if no {id, value} key exists",
         %{
           id: id,
           value: value,
           owner: owner
         } do
      assert owner == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert value == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end

    test "should return :ok if {id, value} key exists and has owner as a value",
         %{
           id: id,
           value: value,
           owner: owner
         } do
      assert :ok == @cachex_adapter.claim(id, value, owner)

      assert owner == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert value == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end

    test "should return {:error, :already_exists} if {id, value} key exists but has a different than owner value",
         %{
           id: id,
           value: value,
           owner: owner
         } do
      other = UUID.uuid4()
      assert {:error, :already_exists} == @cachex_adapter.claim(id, value, other)

      assert owner == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert value == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})

      refute other == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert nil == Cachex.get!(@cachex_adapter, {@by_owner_key, id, other})
    end

    test "should release an old {id, value} key if the same owner claims a new value for the same id",
         %{
           id: id,
           value: value,
           owner: owner
         } do
      new_value = Faker.Lorem.sentence()

      assert :ok == @cachex_adapter.claim(id, new_value, owner)

      assert nil == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert owner == Cachex.get!(@cachex_adapter, {@by_value_key, id, new_value})
      assert new_value == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end
  end

  describe "release/3" do
    test "should return :ok and delete {id, owner} and {id, value} if they exist",
         %{
           id: id,
           value: value,
           owner: owner
         } do
      assert :ok == @cachex_adapter.release(id, value, owner)

      assert nil == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert nil == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end

    test "should return :ok if no given value exists" do
      id = :other_field_name
      value = Faker.Lorem.sentence()
      owner = UUID.uuid4()

      assert nil == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert nil == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})

      assert :ok == @cachex_adapter.release(id, value, owner)

      assert nil == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert nil == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end

    test "should return {:error, :claimed_by_another_owner} if claimed with another owner",
         %{
           id: id,
           value: value,
           owner: owner
         } do
      other = UUID.uuid4()
      assert {:error, :claimed_by_another_owner} == @cachex_adapter.release(id, value, other)

      assert owner == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert value == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end
  end

  describe "release/2" do
    test "should return :ok and delete {id, owner} and {id, value} if they are exists",
         %{
           id: id,
           value: value,
           owner: owner
         } do
      assert :ok == @cachex_adapter.release(id, owner)

      assert nil == Cachex.get!(@cachex_adapter, {@by_value_key, id, value})
      assert nil == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end

    test "should return :ok if no given value exists" do
      id = :other_field_name
      owner = UUID.uuid4()

      assert nil == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})

      assert :ok == @cachex_adapter.release(id, owner)

      assert nil == Cachex.get!(@cachex_adapter, {@by_owner_key, id, owner})
    end
  end
end
