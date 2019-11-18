defmodule Club.Brands.Aggregates.Brand do
  @derive Jason.Encoder

  defstruct uuid: nil,
            name: nil,
            url: "",
            product_count: 0,
            products: [],
            deleted?: false

  alias Club.Brands.Aggregates.Brand

  alias Club.Brands.Commands.{
    AddBrand,
    RenameBrand,
    UpdateBrandUrl,
    LinkNewProductWithBrand,
    UnlinkProductFromBrand,
    DeleteBrand
  }

  alias Club.Brands.Events.{
    BrandAdded,
    BrandRenamed,
    BrandUrlUpdated,
    NewProductWithBrandLinked,
    ProductFromBrandUnlinked,
    BrandDeleted
  }

  # AddBrand
  def execute(%Brand{uuid: nil}, %AddBrand{} = cmd), do: BrandAdded.new(cmd)

  def execute(%Brand{}, %AddBrand{}), do: {:error, :brand_already_exists}

  # if Brand doesn't exists we should return error for all but AddBrand commands
  def execute(%Brand{uuid: nil}, _), do: {:error, :brand_doesnt_exist}

  # DeleteBrand
  def execute(%Brand{deleted?: true}, %DeleteBrand{}), do: nil

  def execute(%Brand{product_count: count}, %DeleteBrand{}) when count > 0,
    do: {:error, :brand_has_linked_products}

  def execute(%Brand{}, %DeleteBrand{} = cmd), do: BrandDeleted.new(cmd)

  # if Brand deleted we should return error for all but DeleteBrand commands
  def execute(%Brand{deleted?: true}, _), do: {:error, :brand_has_been_deleted}

  # RenameBrand
  def execute(%Brand{name: name}, %RenameBrand{name: name}), do: nil

  def execute(%Brand{uuid: uuid}, %RenameBrand{brand_uuid: uuid} = cmd), do: BrandRenamed.new(cmd)

  # UpdateBrandUrl
  def execute(%Brand{url: url}, %UpdateBrandUrl{url: url}), do: nil

  def execute(%Brand{uuid: uuid}, %UpdateBrandUrl{brand_uuid: uuid} = cmd),
    do: BrandUrlUpdated.new(cmd)

  # LinkNewProductWithBrand
  def execute(
        %Brand{products: products},
        %LinkNewProductWithBrand{product_uuid: product_uuid} = cmd
      ) do
    case Enum.any?(products, &(&1 == product_uuid)) do
      true -> nil
      _ -> NewProductWithBrandLinked.new(cmd)
    end
  end

  # UnlinkProductFromBrand
  def execute(
        %Brand{products: products},
        %UnlinkProductFromBrand{product_uuid: product_uuid} = cmd
      ) do
    case Enum.any?(products, &(&1 == product_uuid)) do
      true -> ProductFromBrandUnlinked.new(cmd)
      _ -> nil
    end
  end

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

  def apply(
        %Brand{product_count: product_count, products: products} = brand,
        %NewProductWithBrandLinked{
          product_uuid: product_uuid
        }
      ) do
    %Brand{
      brand
      | product_count: product_count + 1,
        products: [product_uuid | products]
    }
  end

  def apply(
        %Brand{product_count: product_count, products: products} = brand,
        %ProductFromBrandUnlinked{
          product_uuid: product_uuid
        }
      ) do
    %Brand{
      brand
      | product_count: product_count - 1,
        products: products -- [product_uuid]
    }
  end

  def apply(
        %Brand{} = brand,
        %BrandDeleted{}
      ) do
    %Brand{
      brand
      | deleted?: true
    }
  end
end
