defmodule Club.Brands.Projections.Brand do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  @primary_key {:brand_uuid, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "brands_brands" do
    field :name, :string
    field :url, :string, null: false, default: ""
    field :product_count, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :url, :product_count])
    |> validate_required([:name, :product_count])
  end
end
