defmodule Club.Brands.Commands.RenameBrand do
  use Commanded.Command,
    brand_uuid: Ecto.UUID,
    name: :string

  @required_fields [
    :brand_uuid,
    :name
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end

defimpl Commanded.Middleware.Uniqueness.UniqueFields, for: Club.Brands.Commands.RenameBrand do
  alias Club.Brands.Commands.RenameBrand
  alias Club.Brands

  def unique(%RenameBrand{brand_uuid: brand_uuid}),
    do: [
      {:name, "has already exist", brand_uuid,
       ignore_case: true, label: :brand, is_unique: &is_unique/4, partition: Club.Brands}
    ]

  def is_unique(:name, value, _owner, _opts), do: Brands.brand_unique?(%{name: value})
end
