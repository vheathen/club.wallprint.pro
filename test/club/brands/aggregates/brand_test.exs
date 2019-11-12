defmodule Club.Brands.Aggregates.BrandTest do
  use Club.AggregateCase,
    aggregate: Club.Brands.Aggregates.Brand

  alias Club.Brands.Aggregates.Brand
  alias Club.Brands.Commands.AddBrand
  alias Club.Brands.Events.BrandAdded

  @tag :unit
  describe "AddBrand command" do
    setup do
      add_brand_cmd = :new_brand |> build() |> AddBrand.new() |> Ecto.Changeset.apply_changes()

      [cmd: add_brand_cmd]
    end

    test "should return BrandAdded event for the first time", %{cmd: cmd} do
      brand_added = BrandAdded.new(cmd)
      assert_events(cmd, [brand_added])
    end

    test "should return {:error, :brand_already_exists} on the second try", %{cmd: cmd} do
      brand_added = BrandAdded.new(cmd)
      assert_error([brand_added], cmd, {:error, :brand_already_exists})
    end
  end
end
