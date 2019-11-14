defmodule TestCommandSimpleCaseInsensitive do
  defstruct [
    :id,
    :name
  ]
end

defimpl Club.Support.Middleware.Uniqueness.UniqueFields, for: TestCommandSimpleCaseInsensitive do
  def unique(%TestCommandSimpleCaseInsensitive{id: id}),
    do: [
      {:name, "has already been taken", id, ignore_case: true}
    ]
end
