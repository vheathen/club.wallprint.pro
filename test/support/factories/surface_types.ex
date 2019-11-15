defmodule Club.Factories.SurfaceTypes do
  defmacro __using__(_opts) do
    quote do
      def surface_type_aggregate_factory do
        %Club.SurfaceTypes.Aggregates.SurfaceType{
          uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword(),
          product_count: 0
        }
      end

      def new_surface_type_factory do
        %{
          surface_type_uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword()
        }
      end
    end
  end
end
