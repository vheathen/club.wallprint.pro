defmodule Club.SurfaceTypes.Projections.SurfaceType do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:surface_type_uuid, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "surface_types_surface_types" do
    field :name, :string
    field :product_count, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :product_count])
    |> validate_required([:name, :product_count])
  end
end
