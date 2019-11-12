defmodule Club.Brands.Commands.AddBrandTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.AddBrand,
    factory: :new_brand

  alias Club.Brands.Commands.AddBrand

  required_fields([
    :brand_uuid,
    :brand_name,
    :user_uuid,
    :user_name
  ])

  optional_fields([
    :brand_url
  ])

  fields(
    :string,
    [
      :brand_name,
      :brand_url,
      :user_name
    ]
  )

  fields(
    Ecto.UUID,
    [
      :brand_uuid,
      :user_uuid
    ]
  )

  # fields(
  #   :url,
  #   [
  #     :brand_url
  #   ]
  # )

  basic_command_tests()

  describe "AddBrand" do
    @tag :unit
    test "incorrect brand url - invalid command" do
      ~w(
        htup://wrong_scheme_url.com
        no_scheme_url.com
        just_a_string
      )
      |> Enum.each(fn url ->
        brand = build(:new_brand, %{brand_url: url})

        %{errors: errors} = cmd = AddBrand.new(brand)
        refute cmd.valid?
        assert Enum.any?(errors, fn {field, {_, [validation: :url]}} -> field == :brand_url end)
      end)
    end
  end
end
