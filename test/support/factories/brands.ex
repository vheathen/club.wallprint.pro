defmodule Club.Factories.Brands do
  defmacro __using__(_opts) do
    quote do
      def new_brand_factory do
        %{
          brand_uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword(),
          url: Faker.Internet.url(),
          user_uuid: UUID.uuid4(),
          user_name: Faker.Name.En.name()
        }
      end

      def rename_brand_factory do
        %{
          brand_uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword(),
          user_uuid: UUID.uuid4(),
          user_name: Faker.Name.En.name()
        }
      end

      def update_url_factory do
        %{
          brand_uuid: UUID.uuid4(),
          url: Faker.Internet.url(),
          user_uuid: UUID.uuid4(),
          user_name: Faker.Name.En.name()
        }
      end
    end
  end
end
