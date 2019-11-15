defmodule Club.SurfaceTypes.Queries.NameExists do
  import Ecto.Query

  alias Club.SurfaceTypes.Projections.SurfaceType

  def new(name) do
    from b in SurfaceType,
      select: true,
      where: fragment("lower(?)", b.name) == ^name,
      limit: 1
  end
end
