defmodule Club.Brands.Aggregates.Brand do
  @derive Jason.Encoder

  defstruct uuid: nil,
            name: nil,
            url: "",
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

  def execute(%Brand{name: name}, %RenameBrand{name: name}), do: nil

  def execute(%Brand{uuid: uuid}, %RenameBrand{brand_uuid: uuid} = cmd), do: BrandRenamed.new(cmd)

  # UpdateBrandUrl
  def execute(%Brand{uuid: nil}, %UpdateBrandUrl{}), do: {:error, :brand_doesnt_exist}

  def execute(%Brand{url: url}, %UpdateBrandUrl{url: url}), do: nil

  def execute(%Brand{uuid: uuid}, %UpdateBrandUrl{brand_uuid: uuid} = cmd),
    do: BrandUrlUpdated.new(cmd)

  # state mutators

  def apply(%Brand{} = brand, %BrandAdded{} = event) do
    %Brand{
      brand
      | uuid: event.brand_uuid,
        name: event.name,
        url: event.url
    }
  end

  def apply(%Brand{} = brand, %BrandRenamed{name: name}) do
    %Brand{
      brand
      | name: name
    }
  end

  def apply(%Brand{} = brand, %BrandUrlUpdated{url: url}) do
    %Brand{
      brand
      | url: url
    }
  end
end
