defmodule Club.Factories.Accounts do
  defmacro __using__(_opts) do
    quote do
      def user_aggregate_factory do
        %Club.Accounts.Aggregates.User{
          uuid: UUID.uuid4(),
          email: Faker.Internet.email(),
          name: Faker.Name.En.name(),
          identities: []
        }
      end

      def new_user_factory do
        %{
          user_uuid: UUID.uuid4(),
          email: Faker.Internet.email(),
          name: Faker.Name.En.name(),
          identity: %{prov: "password", uid: "some_hashed_string"}
        }
      end

      def change_user_name_factory do
        %{
          user_uuid: UUID.uuid4(),
          name: Faker.Name.En.name()
        }
      end

      # def delete_user_factory do
      #   %{
      #     user_uuid: UUID.uuid4()
      #   }
      # end
    end
  end
end
