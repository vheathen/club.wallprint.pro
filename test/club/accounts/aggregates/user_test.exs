defmodule Club.Accounts.Aggregates.UserTest do
  use Club.AggregateCase,
    aggregate: Club.Accounts.Aggregates.User

  alias Club.Accounts.Events.{
    UserRegistered
    # UserDeleted
  }

  setup do
    register_user = register_user_cmd()

    user_aggregate =
      build(:user_aggregate, %{
        uuid: register_user.user_uuid,
        email: register_user.email,
        name: register_user.name,
        identities: [register_user.identity],
        email_confirmed?: false,
        state: :unverified,
        deleted?: false
      })

    [register_user: register_user, user: user_aggregate]
  end

  describe "RegisterUser command" do
    @describetag :unit

    test "should return UserRegistered event for the first time", %{
      register_user: cmd,
      user: user
    } do
      user_registered = UserRegistered.new(cmd)
      assert_events(cmd, [user_registered])
      assert_state(cmd, user)
    end

    test "should return {:error, :user_already_exists} on the second try", %{register_user: cmd} do
      user_registered = UserRegistered.new(cmd)
      assert_error([user_registered], cmd, {:error, :user_already_exists})
    end
  end

  # describe "RenameUser command" do
  #   @describetag :unit

  #   setup %{register_user: register_user, user: user} do
  #     rename_user =
  #       :rename_user
  #       |> build(user_uuid: register_user.user_uuid)
  #       |> RenameUser.new()
  #       |> Ecto.Changeset.apply_changes()

  #     user = %{user | name: rename_user.name}

  #     [register_user: register_user, rename_user: rename_user, user: user]
  #   end

  #   test "should return UserRenamed event for the existing user", %{
  #     register_user: register_user,
  #     rename_user: rename_user,
  #     user: user
  #   } do
  #     user_registered = UserRegistered.new(register_user)
  #     user_renamed = UserRenamed.new(rename_user)
  #     assert_events([user_registered], rename_user, [user_renamed])
  #     assert_state([user_registered], rename_user, user)
  #   end

  #   test "should return {:error, :user_doesnt_exist} if no such user exists", %{
  #     rename_user: rename_user
  #   } do
  #     assert_error(rename_user, {:error, :user_doesnt_exist})
  #   end

  #   test "should not return any events if name is the same as previous one", %{
  #     register_user: register_user,
  #     rename_user: rename_user
  #   } do
  #     user_registered = UserRegistered.new(register_user)
  #     rename_user = %{rename_user | name: user_registered.name}
  #     assert_events([user_registered], rename_user, [])
  #   end
  # end

  # describe "UpdateUserUrl command" do
  #   @describetag :unit

  #   setup %{register_user: register_user, user: user} do
  #     update_url =
  #       :update_url
  #       |> build(user_uuid: register_user.user_uuid)
  #       |> UpdateUserUrl.new()
  #       |> Ecto.Changeset.apply_changes()

  #     user = %{user | url: update_url.url}

  #     [register_user: register_user, update_url: update_url, user: user]
  #   end

  #   test "should return UserUrlChanged event for the existing user", %{
  #     register_user: register_user,
  #     update_url: update_url,
  #     user: user
  #   } do
  #     user_registered = UserRegistered.new(register_user)
  #     url_updated = UserUrlUpdated.new(update_url)
  #     assert_events([user_registered], update_url, [url_updated])
  #     assert_state([user_registered], update_url, user)
  #   end

  #   test "should return {:error, :user_doesnt_exist} if no such user exists", %{
  #     update_url: update_url
  #   } do
  #     assert_error(update_url, {:error, :user_doesnt_exist})
  #   end

  #   test "should not return any events if url is the same as previous one", %{
  #     register_user: register_user,
  #     update_url: update_url
  #   } do
  #     user_registered = UserRegistered.new(register_user)
  #     update_url = %{update_url | url: user_registered.url}
  #     assert_events([user_registered], update_url, [])
  #   end
  # end

  # describe "LinkNewProductWithUser command" do
  #   @describetag :unit

  #   setup %{register_user: register_user} do
  #     link_product = link_product_cmd(user_uuid: register_user.user_uuid)

  #     [register_user: register_user, link_product: link_product]
  #   end

  #   test "should return NewProductWithUserLinked event for the existing user and unseen product_uuid",
  #        %{
  #          register_user: register_user,
  #          link_product: link_product1,
  #          user: user
  #        } do
  #     user_registered = UserRegistered.new(register_user)

  #     product1_linked = NewProductWithUserLinked.new(link_product1)
  #     user1 = %{user | product_count: 1, products: [link_product1.product_uuid]}

  #     assert_events([user_registered], link_product1, [product1_linked])
  #     assert_state([user_registered], link_product1, user1)

  #     link_product2 = link_product_cmd(user_uuid: register_user.user_uuid)
  #     product2_linked = NewProductWithUserLinked.new(link_product2)

  #     user2 = %{
  #       user
  #       | product_count: 2,
  #         products: [link_product2.product_uuid, link_product1.product_uuid]
  #     }

  #     assert_events([user_registered, product1_linked], link_product2, [product2_linked])
  #     assert_state([user_registered, product1_linked], link_product2, user2)
  #   end

  #   test "should return {:error, :user_doesnt_exist} if no such user exists", %{
  #     link_product: link_product
  #   } do
  #     assert_error(link_product, {:error, :user_doesnt_exist})
  #   end

  #   test "should not return any events if product_uuid has already been linked", %{
  #     register_user: register_user,
  #     link_product: link_product
  #   } do
  #     user_registered = UserRegistered.new(register_user)
  #     product_linked = NewProductWithUserLinked.new(link_product)
  #     assert_events([user_registered, product_linked], link_product, [])
  #   end
  # end

  # describe "UnlinkProductFromUser command" do
  #   @describetag :unit

  #   setup %{register_user: register_user, user: user} do
  #     user_registered = UserRegistered.new(register_user)

  #     link_product1 = link_product_cmd(user_uuid: register_user.user_uuid)
  #     product1_linked = NewProductWithUserLinked.new(link_product1)

  #     link_product2 = link_product_cmd(user_uuid: register_user.user_uuid)
  #     product2_linked = NewProductWithUserLinked.new(link_product2)

  #     user2 = %{
  #       user
  #       | product_count: 2,
  #         products: [link_product2.product_uuid, link_product1.product_uuid]
  #     }

  #     [
  #       start_events: [user_registered, product1_linked, product2_linked],
  #       start_state: user2,
  #       p1: product1_linked,
  #       p2: product2_linked
  #     ]
  #   end

  #   test "should return NewProductWithUserLinked event for the existing user and unseen product_uuid",
  #        %{
  #          start_events: start_events,
  #          start_state: %{uuid: user_uuid} = start_state,
  #          p1: %{product_uuid: p1uuid},
  #          p2: %{product_uuid: p2uuid}
  #        } do
  #     unlink_product1 = unlink_product_cmd(user_uuid: user_uuid, product_uuid: p1uuid)
  #     product1_unlinked = ProductFromUserUnlinked.new(unlink_product1)

  #     assert_events(start_events, unlink_product1, [product1_unlinked])

  #     assert_state(start_events, unlink_product1, %{
  #       start_state
  #       | product_count: 1,
  #         products: start_state.products -- [p1uuid]
  #     })

  #     unlink_product2 = unlink_product_cmd(user_uuid: user_uuid, product_uuid: p2uuid)
  #     product2_unlinked = ProductFromUserUnlinked.new(unlink_product2)

  #     assert_events(start_events ++ [product1_unlinked], unlink_product2, [product2_unlinked])

  #     assert_state(start_events ++ [product1_unlinked], unlink_product2, %{
  #       start_state
  #       | product_count: 0,
  #         products: []
  #     })
  #   end

  #   test "should return {:error, :user_doesnt_exist} if no such user exists" do
  #     unlink_product = unlink_product_cmd()
  #     assert_error(unlink_product, {:error, :user_doesnt_exist})
  #   end

  #   test "should not return any events if product_uuid has not been linked", %{
  #     start_events: start_events,
  #     start_state: %{uuid: user_uuid}
  #   } do
  #     unlink_product = unlink_product_cmd(user_uuid: user_uuid)
  #     assert_events(start_events, unlink_product, [])
  #   end
  # end

  # describe "DeleteUser command" do
  #   @describetag :unit

  #   setup %{register_user: register_user, user: user} do
  #     user_registered = UserRegistered.new(register_user)

  #     link_product1 = link_product_cmd(user_uuid: register_user.user_uuid)
  #     product1_linked = NewProductWithUserLinked.new(link_product1)

  #     unlink_product1 =
  #       unlink_product_cmd(
  #         user_uuid: register_user.user_uuid,
  #         product_uuid: link_product1.product_uuid
  #       )

  #     product1_unlinked = ProductFromUserUnlinked.new(unlink_product1)

  #     start_state = %{
  #       user
  #       | product_count: 1,
  #         products: [link_product1.product_uuid]
  #     }

  #     delete_user = delete_user_cmd(user_uuid: start_state.uuid)
  #     user_deleted = UserDeleted.new(delete_user)

  #     [
  #       start_events: [user_registered, product1_linked],
  #       start_state: start_state,
  #       product_unlinked: product1_unlinked,
  #       delete_user: delete_user,
  #       user_deleted: user_deleted
  #     ]
  #   end

  #   test "should return UserDeleted event for the existing user and product_count = 0",
  #        %{
  #          start_events: start_events,
  #          start_state: start_state,
  #          product_unlinked: product1_unlinked,
  #          delete_user: delete_user,
  #          user_deleted: user_deleted
  #        } do
  #     assert_events(start_events ++ [product1_unlinked], delete_user, [user_deleted])

  #     assert_state(start_events ++ [product1_unlinked], delete_user, %{
  #       start_state
  #       | product_count: 0,
  #         products: [],
  #         deleted?: true
  #     })
  #   end

  #   test "should return {:error, :user_doesnt_exist} if no such user exists" do
  #     delete_user = delete_user_cmd()
  #     assert_error(delete_user, {:error, :user_doesnt_exist})
  #   end

  #   test "should return {:error, :user_has_linked_products} if user has linked products", %{
  #     start_events: start_events,
  #     delete_user: delete_user
  #   } do
  #     assert_error(start_events, delete_user, {:error, :user_has_linked_products})
  #   end

  #   test "should not return any events if user already deleted", %{
  #     start_events: start_events,
  #     product_unlinked: product1_unlinked,
  #     delete_user: delete_user,
  #     user_deleted: user_deleted
  #   } do
  #     assert_events(start_events ++ [product1_unlinked, user_deleted], delete_user, [])
  #   end
  # end
end
