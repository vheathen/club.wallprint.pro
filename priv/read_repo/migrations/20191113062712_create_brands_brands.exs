defmodule Club.ReadRepo.Migrations.CreateBrandsBrands do
  use Ecto.Migration

  def change do
    create table(:brands_brands, primary_key: false) do
      add :brand_uuid, :binary_id, primary_key: true
      add :brand_name, :string
      add :brand_url, :string
      add :product_count, :bigint

      timestamps()
    end
  end
end
