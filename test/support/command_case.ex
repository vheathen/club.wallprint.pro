defmodule Club.CommandCase do
  @moduledoc """
  This module defines the setup for a domain commands test.
  """

  use ExUnit.CaseTemplate

  using(opts) do
    command =
      Keyword.get(opts, :command) ||
        raise "use CommandCase, command: CommandModule, factory: :factory_name"

    factory =
      Keyword.get(opts, :factory) ||
        raise "use CommandCase, command: CommandModule, factory: :factory_name"

    quote do
      import Club.Factory
      import Club.CommandCase

      @command unquote(command)
      @factory unquote(factory)
      @test_retries 10

      @required_fields []
      @optional_fields []
      @all_fields []

      @string_fields []
      @integer_fields []
      @float_fields []
      @uuid_fields []
      @url_fields []
    end
  end

  setup do
    {:ok, _} = Application.ensure_all_started(:club)

    default_settings = Application.get_all_env(:club)

    on_exit(fn ->
      Application.put_all_env([{:club, default_settings}])
    end)

    :ok
  end

  @doc """
  Macro for running basic tests:
    - checks for all fields (required + optional)
    - checks that correct attributes, provided by a factory, allow to create a valid command
    - checks that without any of the required fields a new command becomes invalid
    - checks that without any optional fields a new command still valid
    - checks for cast error, mostly to be sure types are set correctly
  """
  defmacro basic_command_tests do
    quote do
      describe "#{@command}" do
        @tag :unit
        test "should contain all necessary fields" do
          assert @all_fields ==
                   @command
                   |> struct()
                   |> Map.from_struct()
                   |> Map.keys()
                   |> Enum.sort()
        end

        @tag :unit
        test "with correct attributes should allow to create a valid command" do
          for _ <- 1..@test_retries,
              do: assert(@command.new(build(@factory)).valid?)
        end

        @tag :unit
        test "without one of the required fields - invalid command" do
          for _ <- 1..@test_retries do
            for req_field <- @required_fields do
              data = @factory |> build() |> Map.delete(req_field)

              %{errors: errors} = cmd = @command.new(data)
              refute cmd.valid?

              assert Enum.any?(
                       errors,
                       fn
                         {^req_field, {_, [validation: :required]}} ->
                           true

                         _ ->
                           false
                       end
                     )
            end
          end
        end

        @tag :unit
        test "without any of the optional fields - valid command" do
          for _ <- 1..@test_retries do
            for opt_field <- @optional_fields do
              data = @factory |> build() |> Map.delete(opt_field)
              assert @command.new(data).valid?
            end
          end
        end

        @tag :unit
        test "with non-string data for string fields - incorrect command" do
          for _ <- 1..@test_retries do
            [
              Faker.Random.Elixir.random_between(-2_000_000_000, 2_000_000_000),
              Faker.Random.Elixir.random_uniform(),
              :simple_atom,
              :"less simple atom",
              'charlist'
            ]
            |> Enum.each(fn non_string ->
              Enum.each(
                @string_fields,
                fn field ->
                  data = build(@factory, %{field => non_string})

                  %{errors: errors} = cmd = @command.new(data)
                  refute cmd.valid?

                  assert Enum.any?(
                           errors,
                           fn
                             {^field, {_, [type: :string, validation: :cast]}} ->
                               true

                             _ ->
                               false
                           end
                         )
                end
              )
            end)
          end
        end

        @tag :unit
        test "with non-integer data for integer fields - incorrect command" do
          for _ <- 1..@test_retries do
            [
              Faker.String.base64(4),
              Faker.Random.Elixir.random_uniform(),
              :simple_atom,
              :"less simple atom",
              'charlist'
            ]
            |> Enum.each(fn non_integer ->
              Enum.each(
                @integer_fields,
                fn field ->
                  data = build(@factory, %{field => non_integer})

                  %{errors: errors} = cmd = @command.new(data)
                  refute cmd.valid?

                  assert Enum.any?(
                           errors,
                           fn
                             {^field, {_, [type: :integer, validation: :cast]}} ->
                               true

                             _ ->
                               false
                           end
                         )
                end
              )
            end)
          end
        end

        @tag :unit
        test "with non-uuid data for uuid fields - incorrect command" do
          for _ <- 1..@test_retries do
            [
              Faker.Random.Elixir.random_between(-2_000_000_000, 2_000_000_000),
              Faker.String.base64(32),
              Faker.String.base64(64),
              Faker.Random.Elixir.random_uniform(),
              :simple_atom,
              :"less simple atom",
              'charlist'
            ]
            |> Enum.each(fn non_uuid ->
              Enum.each(
                @uuid_fields,
                fn field ->
                  data = build(@factory, %{field => non_uuid})

                  %{errors: errors} = cmd = @command.new(data)
                  refute cmd.valid?

                  assert Enum.any?(
                           errors,
                           fn
                             {^field, {_, [type: Ecto.UUID, validation: :cast]}} ->
                               true

                             _ ->
                               false
                           end
                         )
                end
              )
            end)
          end
        end
      end
    end
  end

  defmacro required_fields(fields) when is_list(fields) do
    quote do
      @required_fields (unquote(fields) ++ @required_fields) |> Enum.sort()
      @all_fields (unquote(fields) ++ @all_fields) |> Enum.sort()
    end
  end

  defmacro optional_fields(fields) when is_list(fields) do
    quote do
      @optional_fields (unquote(fields) ++ @optional_fields) |> Enum.sort()
      @all_fields (unquote(fields) ++ @all_fields) |> Enum.sort()
    end
  end

  defmacro get_required_fields, do: quote(do: @required_fields)
  defmacro get_optional_fields, do: quote(do: @optional_fields)
  defmacro get_all_fields, do: quote(do: @all_fields)

  defmacro string_fields(fields),
    do: quote(do: @string_fields((unquote(fields) ++ @string_fields) |> Enum.sort()))

  defmacro integer_fields(fields),
    do: quote(do: @integer_fields((unquote(fields) ++ @integer_fields) |> Enum.sort()))

  defmacro float_fields(fields),
    do: quote(do: @float_fields((unquote(fields) ++ @float_fields) |> Enum.sort()))

  defmacro uuid_fields(fields),
    do: quote(do: @uuid_fields((unquote(fields) ++ @uuid_fields) |> Enum.sort()))

  defmacro url_fields(fields),
    do: quote(do: @url_fields((unquote(fields) ++ @url_fields) |> Enum.sort()))
end
