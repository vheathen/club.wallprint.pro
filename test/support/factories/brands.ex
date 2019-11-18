defmodule Club.Factories.Brands do
  defmacro __using__(_opts) do
    quote do
      def brand_aggregate_factory do
        %Club.Brands.Aggregates.Brand{
          uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword(),
          url: Faker.Internet.url(),
          product_count: 0,
          products: []
        }
      end

      def new_brand_factory do
        %{
          brand_uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword(),
          url: Faker.Internet.url()
        }
      end

      def rename_brand_factory do
        %{
          brand_uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword()
        }
      end

      def update_url_factory do
        %{
          brand_uuid: UUID.uuid4(),
          url: Faker.Internet.url()
        }
      end

      def link_new_product_with_brand_factory do
        %{
          brand_uuid: UUID.uuid4(),
          product_uuid: UUID.uuid4(),
          product_name: Faker.Company.En.buzzword()
        }
      end

      def unlink_product_from_brand_factory do
        %{
          brand_uuid: UUID.uuid4(),
          product_uuid: UUID.uuid4()
        }
      end

      def delete_brand_factory do
        %{
          brand_uuid: UUID.uuid4()
        }
      end
    end
  end
end
