defmodule TestCommandMultiConcat do
  defstruct [
    :id,
    :name,
    :email,
    :description
  ]
end

defimpl Club.Support.Middleware.Uniqueness.UniqueFields, for: TestCommandMultiConcat do
  def unique(%TestCommandMultiConcat{id: id}),
    do: [
      {[:name, :email], "not unique", id, ignore_case: [:email]},
      {:description, "not unique", id}
    ]
end
