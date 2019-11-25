defmodule Club.Accounts.Projectors.UserTest do
  use Club.DataCase

  alias Club.ReadRepo, as: Repo

  alias Club.Accounts

  alias Club.Accounts.Projections.User, as: UserProjection

  alias Club.Accounts.Events.{
    UserRegistered
  }

  @topic "domain:accounts"

  setup do
    Phoenix.PubSub.subscribe(Club.EventBus, @topic)

    user = build(:new_user)

    {:ok, _} = Accounts.register_user(user, meta())

    wait_for_event(Club.Commanded, UserRegistered)

    [user: user]
  end

  describe "Accounts.Projectors.User on" do
    @describetag :integration

    test "UserRegistered event shoud insert a new user record", %{
      user: %{user_uuid: user_uuid} = user
    } do
      assert_receive {:user_registered, %{user_uuid: ^user_uuid}}, 1_000

      result = Repo.all(UserProjection)
      assert length(result) == 1
      [user_projection] = result

      assert user.user_uuid == user_projection.user_uuid
      assert user.name == user_projection.name
      assert user.email == user_projection.email
      assert false == user_projection.email_confirmed?
      assert "unverified" == user_projection.state

      [identity] = user_projection.identities

      assert user.identity.prov == identity.prov
      assert user.identity.uid == identity.uid
    end
  end
end
