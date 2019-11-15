defmodule Club.Brands.Commands.AddBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.AddBrand,
    factory: :new_brand

  alias Club.Brands.Commands.AddBrand

  required_fields([
    :brand_uuid,
    :name
  ])

  optional_fields([
    :url
  ])

  fields(
    :string,
    [
      :url
    ]
  )

  fields(
    Ecto.UUID,
    [
      :brand_uuid
    ]
  )

  # fields(
  #   :url,
  #   [
  #     :url
  #   ]
  # )

  basic_command_tests()

  describe "AddBrand" do
    @describetag :unit

    test "incorrect brand url - invalid command" do
      ~w(
        htup://wrong_scheme_url.com
        no_scheme_url.com
        just_a_string
      )
      |> Enum.each(fn url ->
        brand = build(:new_brand, %{url: url})

        %{errors: errors} = cmd = AddBrand.new(brand)
        refute cmd.valid?
        assert Enum.any?(errors, fn {field, {_, [validation: :url]}} -> field == :url end)
      end)
    end
  end
end
