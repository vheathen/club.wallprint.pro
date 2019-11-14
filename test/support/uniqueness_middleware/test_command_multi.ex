defmodule TestCommandMulti do
  defstruct [
    :id,
    :name,
    :email
  ]
end

defimpl Club.Support.Middleware.Uniqueness.UniqueFields, for: TestCommandMulti do
  def unique(%TestCommandMulti{id: id}),
    do: [
      {:name, "has already been taken", id},
      {:email, "has already been taken", id, ignore_case: true}
    ]
end
