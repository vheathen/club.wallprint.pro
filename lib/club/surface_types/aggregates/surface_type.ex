defmodule Club.SurfaceTypes.Aggregates.SurfaceType do
  @derive Jason.Encoder

  defstruct uuid: nil,
            name: nil,
            product_count: 0,
            products: [],
            deleted?: false

  alias Club.SurfaceTypes.Aggregates.SurfaceType

  alias Club.SurfaceTypes.Commands.{
    AddSurfaceType,
    DeleteSurfaceType,
    RenameSurfaceType,
    AddSurfaceTypeSupportToProduct,
    WithdrawSurfaceTypeSupportFromProduct
  }

  alias Club.SurfaceTypes.Events.{
    SurfaceTypeAdded,
    SurfaceTypeDeleted,
    SurfaceTypeRenamed,
    SurfaceTypeSupportToProductAdded,
    SurfaceTypeSupportFromProductWithdrawn
  }

  # AddSurfaceType
  def execute(%SurfaceType{uuid: nil}, %AddSurfaceType{} = cmd), do: SurfaceTypeAdded.new(cmd)

  def execute(%SurfaceType{}, %AddSurfaceType{}), do: {:error, :surface_type_already_exists}

  # if SurfaceType doesn't exists we should return error for all but AddSurfaceType commands
  def execute(%SurfaceType{uuid: nil}, _),
    do: {:error, :surface_type_doesnt_exist}

  # DeleteSurfaceType
  def execute(%SurfaceType{deleted?: true}, %DeleteSurfaceType{}), do: nil

  def execute(%SurfaceType{product_count: count}, %DeleteSurfaceType{}) when count > 0,
    do: {:error, :surface_type_is_linked_to_products}

  def execute(%SurfaceType{}, %DeleteSurfaceType{} = cmd), do: SurfaceTypeDeleted.new(cmd)

  # if SurfaceType deleted we should return error for all but DeleteSurfaceType commands
  def execute(%SurfaceType{deleted?: true}, _), do: {:error, :surface_type_has_been_deleted}

  # RenameSurfaceType
  def execute(%SurfaceType{name: name}, %RenameSurfaceType{name: name}), do: nil

  def execute(%SurfaceType{uuid: uuid}, %RenameSurfaceType{surface_type_uuid: uuid} = cmd),
    do: SurfaceTypeRenamed.new(cmd)

  # AddSurfaceTypeSupportToProduct
  def execute(
        %SurfaceType{products: products},
        %AddSurfaceTypeSupportToProduct{product_uuid: product_uuid} = cmd
      ) do
    case Enum.any?(products, &(&1 == product_uuid)) do
      true -> nil
      _ -> SurfaceTypeSupportToProductAdded.new(cmd)
    end
  end

  # WithdrawSurfaceTypeSupportFromProduct
  def execute(
        %SurfaceType{products: products},
        %WithdrawSurfaceTypeSupportFromProduct{product_uuid: product_uuid} = cmd
      ) do
    case Enum.any?(products, &(&1 == product_uuid)) do
      true -> SurfaceTypeSupportFromProductWithdrawn.new(cmd)
      _ -> nil
    end
  end

  # state mutators

  # AddSurfaceType
  def apply(%SurfaceType{} = surface_type, %SurfaceTypeAdded{} = event) do
    %SurfaceType{
      surface_type
      | uuid: event.surface_type_uuid,
        name: event.name
    }
  end

  def apply(%SurfaceType{} = surface_type, %SurfaceTypeRenamed{name: name}) do
    %SurfaceType{
      surface_type
      | name: name
    }
  end

  def apply(
        %SurfaceType{product_count: product_count, products: products} = surface_type,
        %SurfaceTypeSupportToProductAdded{
          product_uuid: product_uuid
        }
      ) do
    %SurfaceType{
      surface_type
      | product_count: product_count + 1,
        products: [product_uuid | products]
    }
  end

  def apply(
        %SurfaceType{product_count: product_count, products: products} = surface_type,
        %SurfaceTypeSupportFromProductWithdrawn{
          product_uuid: product_uuid
        }
      ) do
    %SurfaceType{
      surface_type
      | product_count: product_count - 1,
        products: products -- [product_uuid]
    }
  end

  def apply(
        %SurfaceType{} = surface_type,
        %SurfaceTypeDeleted{}
      ) do
    %SurfaceType{
      surface_type
      | deleted?: true
    }
  end
end
