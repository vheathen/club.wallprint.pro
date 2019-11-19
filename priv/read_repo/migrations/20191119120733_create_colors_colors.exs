defmodule Club.ReadRepo.Migrations.CreateColorsColors do
  use Ecto.Migration

  def change do
    create table(:colors_colors, primary_key: false) do
      add :color_uuid, :binary_id, primary_key: true
      add :name, :string
      add :hex, :string
      add :thing_count, :bigint

      timestamps()
    end

    create index("colors_colors", ["lower(name)"], name: :color_lower_name_idx)
    create index("colors_colors", [:hex], name: :color_hex_idx)
  end
end
