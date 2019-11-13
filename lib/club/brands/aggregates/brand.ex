defmodule Club.Brands.Aggregates.Brand do
  @derive Jason.Encoder

  defstruct uuid: nil,
            brand_name: nil,
            brand_url: "",
            product_count: 0

  alias Club.Brands.Aggregates.Brand

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl
  }

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated
  }

  # AddBrand
  def execute(%Brand{uuid: nil}, %AddBrand{} = cmd), do: BrandAdded.new(cmd)

  def execute(%Brand{}, %AddBrand{}), do: {:error, :brand_already_exists}

  # RenameBrand
  def execute(%Brand{uuid: nil}, %RenameBrand{}), do: {:error, :brand_doesnt_exist}

  def execute(%Brand{brand_name: brand_name}, %RenameBrand{brand_name: brand_name}), do: nil

  def execute(%Brand{uuid: uuid}, %RenameBrand{brand_uuid: uuid} = cmd), do: BrandRenamed.new(cmd)

  # UpdateBrandUrl
  def execute(%Brand{uuid: nil}, %UpdateBrandUrl{}), do: {:error, :brand_doesnt_exist}

  def execute(%Brand{brand_url: brand_url}, %UpdateBrandUrl{brand_url: brand_url}), do: nil

  def execute(%Brand{uuid: uuid}, %UpdateBrandUrl{brand_uuid: uuid} = cmd),
    do: BrandUrlUpdated.new(cmd)

  # state mutators

  def apply(%Brand{} = brand, %BrandAdded{} = event) do
    %Brand{
      brand
      | uuid: event.brand_uuid,
        brand_name: event.brand_name,
        brand_url: event.brand_url
    }
  end

  def apply(%Brand{} = brand, %BrandRenamed{brand_name: brand_name}) do
    %Brand{
      brand
      | brand_name: brand_name
    }
  end

  def apply(%Brand{} = brand, %BrandUrlUpdated{brand_url: brand_url}) do
    %Brand{
      brand
      | brand_url: brand_url
    }
  end
end
