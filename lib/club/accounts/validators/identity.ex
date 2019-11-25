defmodule Club.Accounts.Validators.Identity do
  import Ecto.Changeset

  def validate_identity_format(changeset, field, opts \\ []) do
    validate_change(changeset, field, fn :identity, identity ->
      identity
      |> case do
        %{prov: _, uid: _} -> []
        %{prov: _} -> [:uid]
        %{uid: _} -> [:prov]
        _ -> [:prov, :uid]
      end
      |> case do
        [] ->
          []

        missing_keys ->
          [
            {field,
             {message(opts, "required key(s) missing"),
              [validation: :identity, keys: missing_keys]}}
          ]
      end
      |> validate_identity_additional_keys(field, identity, opts)
    end)
  end

  defp validate_identity_additional_keys(errors, field, identity, opts) do
    case Map.keys(identity) -- [:prov, :uid] do
      [] ->
        errors

      irrelevant_keys ->
        [
          {field,
           {message(opts, "has irrelevant keys"), [validation: :identity, keys: irrelevant_keys]}}
          | errors
        ]
    end
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
