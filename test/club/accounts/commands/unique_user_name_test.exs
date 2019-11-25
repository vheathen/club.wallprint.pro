defmodule Club.Accounts.Commands.UniqueUserNameTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo
  require Cachex.Spec

  alias Club.Accounts
  alias Club.Accounts.Projections.User, as: UserProjection

  @uniqueness_key Club.Support.Unique
  @cachex_adapter Module.concat(@uniqueness_key, Cachex)

  @topic "domain:accounts"

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

    %{user_uuid: uuid} = user = new_user()
    {:ok, _} = Accounts.register_user(user, meta())

    assert_receive {:user_registered, %{user_uuid: ^uuid}}, 1_000

    [user: user]
  end

  describe "RegisterUser" do
    @describetag :integration

    test "with unique name and email should succeed" do
      %{user_uuid: uuid} = user = new_user()
      {:ok, _} = Accounts.register_user(user, meta())
      assert_receive {:user_registered, %{user_uuid: ^uuid}}, 1_000
      assert length(Repo.all(UserProjection)) == 2
    end

    test "with duplicate name should fail based on the cached results", %{user: user} do
      uuid = UUID.uuid4()
      user = %{user | user_uuid: uuid, email: unique_email(user.email)}
      Repo.delete_all(UserProjection)
      result = Accounts.register_user(user, meta())
      assert result == {:error, :validation_failure, [name: "has already taken"]}
    end

    test "with duplicate name should fail based on the readstore results", %{user: user} do
      uuid = UUID.uuid4()
      user = %{user | user_uuid: uuid, email: unique_email(user.email)}
      Cachex.clear(@cachex_adapter)
      result = Accounts.register_user(user, meta())
      assert result == {:error, :validation_failure, [name: "has already taken"]}
    end

    test "with duplicate email should fail based on the cached results", %{user: user} do
      uuid = UUID.uuid4()
      user = %{user | user_uuid: uuid, name: unique_name(user.name)}
      Repo.delete_all(UserProjection)
      result = Accounts.register_user(user, meta())
      assert result == {:error, :validation_failure, [email: "has already taken"]}
    end

    test "with duplicate email should fail based on the readstore results", %{user: user} do
      uuid = UUID.uuid4()
      user = %{user | user_uuid: uuid, name: unique_name(user.name)}
      Cachex.clear(@cachex_adapter)
      result = Accounts.register_user(user, meta())
      assert result == {:error, :validation_failure, [email: "has already taken"]}
    end
  end

  defp new_user(attrs \\ []) do
    build(:new_user, attrs)
  end

  defp unique_name(old_name) do
    name = Faker.Name.En.name()

    case name != old_name do
      true -> name
      false -> unique_name(old_name)
    end
  end

  defp unique_email(old_email) do
    email = Faker.Internet.email()

    case email != old_email do
      true -> email
      false -> unique_email(old_email)
    end
  end
end
