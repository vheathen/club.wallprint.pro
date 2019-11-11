defmodule Club.Support.Router do
  @moduledoc """
  Router template for all domains.

  Might be optionally used with `local_middleware: middleware_module_list :: list()` option.

  ## Example

      defmodule Some.Domain.Router do
        use Club.Support.Router,
          local_middleware: [
            Some.Domain.LocalMiddleware
          ]
      end

  """

  @doc false
  defmacro __using__(opts \\ []) do
    quote do
      use Commanded.Commands.Router

      import unquote(__MODULE__)

      middleware(Commanded.Middleware.Auditing)

      local_middleware(unquote(Keyword.get(opts, :local_middleware)))
    end
  end

  defmacro local_middleware([]), do: []

  defmacro local_middleware([_ | _] = local_middleware) do
    local_middleware
    |> Enum.map(fn module ->
      quote do
        middleware(unquote(module))
      end
    end)
  end

  defmacro local_middleware(_), do: []
end
