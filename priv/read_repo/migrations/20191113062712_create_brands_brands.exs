defmodule Club.ReadRepo.Migrations.CreateBrandsBrands do
  use Ecto.Migration

  def change do
    create table(:brands_brands, primary_key: false) do
      add :brand_uuid, :binary_id, primary_key: true
      add :name, :string
      add :url, :string
      add :product_count, :bigint

      timestamps()
    end

    create index("brands_brands", ["lower(name)"], name: :brand_lower_name_idx)
  end
end
