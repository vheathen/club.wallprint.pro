defmodule Club.Support.Validators do
  @moduledoc """
  Custom validators interface
  """

  alias Club.Support.Validators

  @spec validate_url(map, atom, Keyword.t()) :: Ecto.Changeset.t()
  defdelegate validate_url(dataset, field, opts \\ []),
    to: Validators.Url,
    as: :call
end
