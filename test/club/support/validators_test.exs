defmodule Club.Support.ValidatorsTest do
  use ExUnit.Case

  import Club.Support.Validators

  describe "validate_url" do
    setup context do
      dataset =
        case context do
          %{url: url} -> Ecto.Changeset.cast({%{}, %{url: :string}}, %{url: url}, [:url])
          _ -> nil
        end

      {:ok, dataset: dataset}
    end

    @tag unit: true, url: "http://microsoft.com/some_path"
    test "must be valid on a proper url", %{dataset: dataset} do
      assert %{valid?: true, errors: []} = validate_url(dataset, :url)
    end

    @tag unit: true, url: "//microsoft.com/some_path"
    test "must return error on scheme absence", %{dataset: dataset} do
      assert %{valid?: false, errors: [url: {"doesn't have scheme", [validation: :url]}]} =
               validate_url(dataset, :url)
    end

    @tag unit: true, url: "//microsoft.com/some_path"
    test "must return custom error on scheme absence", %{dataset: dataset} do
      custom_error = "no scheme"

      assert %{valid?: false, errors: [url: {^custom_error, [validation: :url]}]} =
               validate_url(dataset, :url, no_scheme_message: custom_error)
    end

    @tag unit: true, url: "ftp://microsoft.com/some_path"
    test "must return error when scheme is not on the list allowed_schemes: []", %{
      dataset: dataset
    } do
      assert %{valid?: false, errors: [url: {"scheme not allowed", [validation: :url]}]} =
               validate_url(dataset, :url, allowed_schemes: ["http", "https"])
    end

    @tag unit: true, url: "ftp://microsoft.com/some_path"
    test "must return custom error when scheme is not on the list allowed_schemes: []", %{
      dataset: dataset
    } do
      custom_error = "scheme is not in the allowed list"

      assert %{valid?: false, errors: [url: {^custom_error, [validation: :url]}]} =
               validate_url(
                 dataset,
                 :url,
                 allowed_schemes: ["http", "https"],
                 scheme_not_allowed_message: custom_error
               )
    end

    @tag unit: true, url: "http://microsoft.com/some_path"
    test "must be valid on a proper url with resolvable host name if resolve: true set", %{
      dataset: dataset
    } do
      assert %{valid?: true, errors: []} = validate_url(dataset, :url, resolve: true)
    end

    @tag unit: true, url: "smb://#{UUID.uuid4()}.com/some_path"
    test "must return error on a proper url with unresolvable host name if resolve: true set", %{
      dataset: dataset
    } do
      assert %{valid?: false, errors: [url: {"hostname unknown: NXDOMAIN", [validation: :url]}]} =
               validate_url(dataset, :url, resolve: true)
    end

    @tag unit: true, url: "smb://#{UUID.uuid4()}.com/some_path"
    test "must return custom error on a proper url with unresolvable host name if resolve: true set",
         %{dataset: dataset} do
      #
      custom_error = "can't resolve domain"

      assert %{valid?: false, errors: [url: {^custom_error, [validation: :url]}]} =
               validate_url(dataset, :url, resolve: true, unresolvable_message: custom_error)
    end

    @tag unit: true, url: "smb://#{UUID.uuid4()}.com/some_path"
    test "must return a list of errors", %{dataset: dataset} do
      unresolvable_message = "can't resolve hostname"
      scheme_not_allowed_message = "scheme not allowed"

      validation_result =
        validate_url(
          dataset,
          :url,
          resolve: true,
          unresolvable_message: unresolvable_message,
          allowed_schemes: ["http", "https"],
          scheme_not_allowed_message: scheme_not_allowed_message
        )

      assert %{valid?: false, errors: errors} = validation_result
      assert {:url, {unresolvable_message, [validation: :url]}} in errors
      assert {:url, {scheme_not_allowed_message, [validation: :url]}} in errors
      assert length(errors) == 2
    end
  end
end
