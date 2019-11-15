defmodule Club.Brands.Commands.AddBrand do
  use Commanded.Command,
    brand_uuid: Ecto.UUID,
    name: :string,
    url: :string,
    user_uuid: Ecto.UUID,
    user_name: :string

  import Club.Support.Validators

  @required_fields [
    :brand_uuid,
    :name,
    :user_uuid,
    :user_name
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_url(:url, allowed_schemes: ["http", "https"])
  end
end

defimpl Club.Support.Middleware.Uniqueness.UniqueFields, for: Club.Brands.Commands.AddBrand do
  alias Club.Brands.Commands.AddBrand
  alias Club.Brands

  def unique(%AddBrand{brand_uuid: brand_uuid}),
    do: [
      {:name, "has already exist", brand_uuid,
       ignore_case: true, label: :brand, is_unique: &is_unique/4}
    ]

  def is_unique(:name, value, _owner, _opts), do: Brands.brand_unique?(%{name: value})
end
