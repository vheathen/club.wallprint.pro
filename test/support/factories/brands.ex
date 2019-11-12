defmodule Club.Factories.Brands do
  defmacro __using__(_opts) do
    quote do
      def new_brand_factory do
        %{
          brand_uuid: UUID.uuid4(),
          brand_name: Faker.Company.En.buzzword(),
          brand_url: Faker.Internet.url(),
          user_uuid: UUID.uuid4(),
          user_name: Faker.Name.En.name()
        }
      end
    end
  end
end
