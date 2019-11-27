defmodule Club.Brands.Projectors.UniquenessCache do
  use Commanded.Event.Handler,
    application: Club.Commanded,
    name: __MODULE__

  alias Club.Brands.Events.BrandDeleted

  def handle(%BrandDeleted{brand_uuid: brand_uuid}, _metadata) do
    case Commanded.Middleware.Uniqueness.Adapter.get() do
      nil ->
        :ok

      adapter ->
        :ok = adapter.release(:name, brand_uuid, Club.Brands)
    end
  end
end
