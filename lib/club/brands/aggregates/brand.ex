defmodule Club.Brands.Aggregates.Brand do
  @derive Jason.Encoder

  defstruct uuid: nil,
            brand_name: nil,
            brand_url: "",
            product_count: 0

  alias __MODULE__
  alias Club.Brands.Commands.AddBrand
  alias Club.Brands.Events.BrandAdded

  def execute(%Brand{uuid: nil}, %AddBrand{} = cmd) do
    BrandAdded.new(cmd)
  end

  def execute(%Brand{}, %AddBrand{}), do: {:error, :brand_already_exists}

  def apply(%Brand{} = brand, %BrandAdded{} = event) do
    %Brand{
      brand
      | uuid: event.brand_uuid,
        brand_name: event.brand_name,
        brand_url: event.brand_url
    }
  end
end
