defmodule Club.Factories.Colors do
  defmacro __using__(_opts) do
    quote do
      def color_aggregate_factory do
        %Club.Colors.Aggregates.Color{
          uuid: UUID.uuid4(),
          name: Faker.Color.En.name(),
          hex: Faker.Color.rgb_hex() |> String.downcase(),
          thing_count: 0,
          things: []
        }
      end

      def new_color_factory do
        %{
          color_uuid: UUID.uuid4(),
          name: Faker.Color.En.name(),
          hex: Faker.Color.rgb_hex() |> String.downcase()
        }
      end

      def rename_color_factory do
        %{
          color_uuid: UUID.uuid4(),
          name: Faker.Company.En.buzzword()
        }
      end

      def update_color_hex_factory do
        %{
          color_uuid: UUID.uuid4(),
          hex: Faker.Color.rgb_hex() |> String.downcase()
        }
      end

      def use_color_factory do
        %{
          color_uuid: UUID.uuid4(),
          thing_uuid: UUID.uuid4()
        }
      end

      def stop_using_color_factory do
        %{
          color_uuid: UUID.uuid4(),
          thing_uuid: UUID.uuid4()
        }
      end

      def delete_color_factory do
        %{
          color_uuid: UUID.uuid4()
        }
      end
    end
  end
end
