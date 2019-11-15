defmodule Club.Factories.Devices do
  defmacro __using__(_opts) do
    quote do
      def device_aggregate_factory do
        %Club.Devices.Aggregates.Device{
          uuid: UUID.uuid4(),
          model: Faker.Code.iban(),
          sku: Faker.Code.iban(),
          url: Faker.Internet.url(),
          description: Faker.Lorem.sentence(),
          brand_uuid: UUID.uuid4(),
          product_count: 0
        }
      end

      def new_device_factory do
        %{
          device_uuid: UUID.uuid4(),
          model: Faker.Code.iban(),
          sku: Faker.Code.iban(),
          url: Faker.Internet.url(),
          description: Faker.Lorem.sentence(),
          brand_uuid: UUID.uuid4(),
          brand_name: Faker.Company.En.buzzword()
        }
      end
    end
  end
end
