defmodule Club.Colors.Projections.Color do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:color_uuid, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "colors_colors" do
    field :name, :string
    field :hex, :string, null: false, default: ""
    field :thing_count, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :hex, :thing_count])
    |> validate_required([:name, :thing_count])
  end
end
