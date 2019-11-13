defmodule Club.Brands.Commands.UpdateBrandUrlTest do
  use Club.CommandCase,
    command: Club.Brands.Commands.UpdateBrandUrl,
    factory: :update_brand_url

  alias Club.Brands.Commands.UpdateBrandUrl

  required_fields([
    :brand_uuid,
    :brand_url,
    :user_uuid,
    :user_name
  ])

  fields(
    :string,
    [
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

  basic_command_tests()

  describe "UpdateBrandUrl" do
    @tag :unit
    test "incorrect brand url - invalid command" do
      ~w(
        htup://wrong_scheme_url.com
        no_scheme_url.com
        just_a_string
      )
      |> Enum.each(fn url ->
        brand = build(:update_brand_url, %{brand_url: url})

        %{errors: errors} = cmd = UpdateBrandUrl.new(brand)
        refute cmd.valid?
        assert Enum.any?(errors, fn {field, {_, [validation: :url]}} -> field == :brand_url end)
      end)
    end
  end
end
