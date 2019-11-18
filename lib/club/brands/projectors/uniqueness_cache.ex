defmodule Club.Brands.Projectors.UniquenessCache do
  use Commanded.Event.Handler,
    application: Club.Commanded,
    name: __MODULE__

  alias Club.Support.Config

  alias Club.Brands.Events.BrandDeleted

  def handle(%BrandDeleted{brand_uuid: brand_uuid}, _metadata) do
    case Config.get_sub(Club.Support.Unique, :adapter) do
      nil ->
        :ok

      adapter ->
        :ok = adapter.release(:name, brand_uuid)
    end
  end
end
