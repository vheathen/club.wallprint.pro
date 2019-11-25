defmodule Club.AccountsTest do
  use Club.DataCase

  alias Commanded.Aggregates.Aggregate

  alias Club.Commanded

  alias Club.Accounts
  alias Club.Accounts.Aggregates.User

  alias Club.Accounts.Events.{
    UserRegistered
  }

  describe "register_user/2" do
    @describetag :integration
    test "should succeed and return a new user_uuid if parameters are correct but doesn't contain user_uuid" do
      user = :new_user |> build() |> Map.delete(:user_uuid)
      {:ok, user_uuid} = Accounts.register_user(user, meta())

      assert_receive_event(Commanded, UserRegistered, fn event ->
        assert user_uuid == event.user_uuid
        assert user.name == event.name
        assert user.email == event.email
        assert user.identity == event.identity
      end)

      assert Aggregate.aggregate_state(Commanded, User, "user-" <> user_uuid) ==
               %User{
                 uuid: user_uuid,
                 name: user.name,
                 email: user.email,
                 identities: [user.identity],
                 email_confirmed?: false,
                 state: :unverified,
                 deleted?: false
               }
    end

    test "should succeed and return provided user_uuid if parameters are correct" do
      user = :new_user |> build()
      {:ok, user_uuid} = Accounts.register_user(user, meta())

      assert user_uuid == user.user_uuid
    end

    test "should fail and return error if parameters are incorrect" do
      user =
        :new_user
        |> build()
        |> Map.delete(:user_uuid)
        |> Map.delete(:name)

      {:error, {:validation_failure, %{name: _}}} = Accounts.register_user(user, meta())
    end

    test "should fail and return error if no user_uuid and user_name in metadata" do
      user = :new_user |> build()
      meta = %{}

      assert Accounts.register_user(user, meta) ==
               {:error, :validation_failure,
                [
                  {:user_name, "must be provided"},
                  {:user_uuid, "must be provided"}
                ]}
    end
  end

  describe "user_name_unique?/1" do
    @describetag :integration

    setup :prepare_user

    test "should return true if there is no such user", %{
      user: %{name: existing_name}
    } do
      unique_name = unique_name(existing_name)

      assert Accounts.user_name_unique?(unique_name)
    end

    test "should return false if the user exists", %{
      user: user
    } do
      refute Accounts.user_name_unique?(user.name)
    end

    def unique_name(old_name) do
      name = Faker.Name.En.name()

      case name != old_name do
        true -> name
        false -> unique_name(old_name)
      end
    end
  end

  describe "user_email_unique?/1" do
    @describetag :integration

    setup :prepare_user

    test "should return true if there is no such user", %{
      user: %{email: existing_email}
    } do
      unique_email = unique_email(existing_email)

      assert Accounts.user_email_unique?(unique_email)
    end

    test "should return false if the user exists", %{
      user: user
    } do
      refute Accounts.user_email_unique?(user.email)
    end

    def unique_email(old_email) do
      email = Faker.Internet.email()

      case email != old_email do
        true -> email
        false -> unique_email(old_email)
      end
    end
  end

  def prepare_user(_context) do
    Phoenix.PubSub.subscribe(Club.EventBus, "domain:accounts")

    %{user_uuid: user_uuid} = user = build(:new_user)
    {:ok, _} = Accounts.register_user(user, meta())

    assert_receive {:user_registered, %{user_uuid: ^user_uuid}}, 1_000

    [user: user]
  end
end
