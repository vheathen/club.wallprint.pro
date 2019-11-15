defmodule Club.ReadRepo.Migrations.CreateSurfaceTypesSurfaceTypes do
  use Ecto.Migration

  def change do
    create table(:surface_types_surface_types, primary_key: false) do
      add :surface_type_uuid, :binary_id, primary_key: true
      add :name, :string
      add :product_count, :bigint

      timestamps()
    end

    create index("surface_types_surface_types", ["lower(name)"],
             name: :surface_types_lower_name_idx
           )
  end
end
