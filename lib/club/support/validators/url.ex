defmodule Club.Support.Validators.Url do
  @moduledoc false

  alias Ecto.Changeset

  @validation :url

  # @default_message "isn't a proper url"
  @default_unresolvable_message "hostname unknown: NXDOMAIN"
  @default_no_scheme_message "doesn't have scheme"
  @default_scheme_not_allowed_message "scheme not allowed"
  @default_no_host_message "doesn't have host"

  def call(changeset, field, opts \\ []) do
    case Enum.any?(
           Map.get(changeset, :errors),
           &(&1 == {field, [type: :string, validation: :cast]})
         ) do
      true ->
        changeset

      _ ->
        Changeset.validate_change(changeset, field, fn _current_field, value ->
          parsed_url = value |> URI.parse()

          []
          |> validate_scheme(field, opts, parsed_url)
          |> validate_host(field, opts, parsed_url)
        end)
    end
  end

  defp validate_scheme(errors, field, opts, %URI{scheme: scheme}) do
    scheme_not_allowed_message =
      Keyword.get(opts, :scheme_not_allowed_message, @default_scheme_not_allowed_message)

    no_scheme_message = Keyword.get(opts, :no_scheme_message, @default_no_scheme_message)
    allowed_schemes = opts |> Keyword.get(:allowed_schemes, nil) |> downcase_schemes()

    cond do
      is_nil(scheme) && is_nil(allowed_schemes) ->
        add_error(errors, field, no_scheme_message)

      is_nil(allowed_schemes) || scheme in allowed_schemes ->
        []

      true ->
        add_error(errors, field, scheme_not_allowed_message)
    end
  end

  defp validate_host(errors, field, opts, %URI{host: host}) do
    unresolvable_message = Keyword.get(opts, :unresolvable_message, @default_unresolvable_message)
    no_host_message = Keyword.get(opts, :no_host_message, @default_no_host_message)
    resolve = Keyword.get(opts, :resolve, false)
    no_host = Keyword.get(opts, :no_host, false)

    cond do
      is_nil(host) && no_host ->
        []

      is_nil(host) ->
        add_error(errors, field, no_host_message)

      resolve ->
        case :inet.gethostbyname(Kernel.to_charlist(host)) do
          {:ok, _} -> []
          {:error, _} -> add_error(errors, field, unresolvable_message)
        end

      true ->
        errors
    end
  end

  defp downcase(nil), do: nil
  defp downcase(string) when is_binary(string), do: String.downcase(string)

  defp downcase_schemes(nil), do: nil
  defp downcase_schemes([_ | _] = schemes), do: Enum.map(schemes, &downcase/1)

  defp add_error(errors, field, message) do
    [{field, {message, [validation: @validation]}} | errors]
  end
end
