defmodule TestCommandSimple do
  defstruct [
    :id,
    :name
  ]
end

defimpl Club.Support.Middleware.Uniqueness.UniqueFields, for: TestCommandSimple do
  def unique(%TestCommandSimple{id: id}),
    do: [
      {:name, "has already been taken", id}
    ]
end
