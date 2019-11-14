defmodule Club.Brands.Commands.RenameBrand do
  use Commanded.Command,
    brand_uuid: Ecto.UUID,
    brand_name: :string,
    user_uuid: Ecto.UUID,
    user_name: :string

  @required_fields [
    :brand_uuid,
    :brand_name,
    :user_uuid,
    :user_name
  ]

  def handle_validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end
end

defimpl Club.Support.Middleware.Uniqueness.UniqueFields, for: Club.Brands.Commands.RenameBrand do
  alias Club.Brands.Commands.RenameBrand
  alias Club.Brands

  def unique(%RenameBrand{brand_uuid: brand_uuid}),
    do: [
      {:brand_name, "has already exist", brand_uuid,
       ignore_case: true, label: :brand, is_unique: &is_unique/4}
    ]

  def is_unique(:brand_name, value, _owner, _opts), do: Brands.brand_unique?(%{brand_name: value})
end
