defmodule Club.Support.Middleware.UniquenessTest do
  use ExUnit.Case

  require Cachex.Spec

  alias Commanded.Middleware.Pipeline

  alias Club.Support.Middleware.Uniqueness

  @uniqueness_key Club.Support.Unique
  @cachex_adapter Module.concat(@uniqueness_key, Cachex)

  setup_all do
    case Cachex.get(@cachex_adapter, :anything) do
      {:error, :no_cache} ->
        Application.put_env(:club, @uniqueness_key, adapter: @cachex_adapter)

        {:ok, _} =
          Cachex.start_link(@cachex_adapter, expiration: Cachex.Spec.expiration(default: 100))

      {:ok, _} ->
        true
    end

    :ok
  end

  setup do
    on_exit(fn ->
      Cachex.clear(@cachex_adapter)
    end)
  end

  describe "Uniqueness middleware, TestCommandSimple should" do
    @describetag :unit

    test "continue if field value unique" do
      cmd = %TestCommandSimple{id: 1, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      cmd = %TestCommandSimple{id: 2, name: "NewName2"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end

    test "continue if field value in in another case" do
      cmd = %TestCommandSimple{id: 1, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      #
      cmd = %TestCommandSimple{id: 2, name: "newnaME"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end

    test "should halt if field value not unique" do
      cmd = %TestCommandSimple{id: 1, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandSimple{id: 2, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:name, "has already been taken"}]}
    end
  end

  describe "Uniqueness middleware, TestCommandSimpleLabel should" do
    @describetag :unit

    test "should halt if field value not unique with custom label" do
      cmd = %TestCommandSimpleLabel{id: 1, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandSimpleLabel{id: 2, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted

      assert p.response ==
               {:error, :validation_failure, [{:another_label, "has already been taken"}]}
    end
  end

  describe "Uniqueness middleware, TestCommandSimpleCaseInsensitive should" do
    @describetag :unit

    test "should continue if field value unique" do
      cmd = %TestCommandSimpleCaseInsensitive{id: 1, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      cmd = %TestCommandSimpleCaseInsensitive{id: 2, name: "NewName2"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end

    test "halt if field value not unique even if it's in another case" do
      cmd = %TestCommandSimpleCaseInsensitive{id: 1, name: "NewName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandSimpleCaseInsensitive{id: 2, name: "newnaME"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:name, "has already been taken"}]}
    end
  end

  describe "Uniqueness middleware, TestCommandMulti should" do
    @describetag :unit

    test "continue if field value unique" do
      cmd = %TestCommandMulti{id: 1, name: "NewName", email: "one@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      #
      cmd = %TestCommandMulti{id: 2, name: "newname", email: "another@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end

    test "halt if 'name' field value not unique" do
      cmd = %TestCommandMulti{id: 1, name: "NewName", email: "one@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandMulti{id: 2, name: "NewName", email: "another@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:name, "has already been taken"}]}
    end

    test "halt if 'email' field value not unique" do
      cmd = %TestCommandMulti{id: 1, name: "NewName", email: "one@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandMulti{id: 2, name: "newname", email: "one@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:email, "has already been taken"}]}
    end

    test "halt if 'email' field value not unique even in another case" do
      cmd = %TestCommandMulti{id: 1, name: "NewName", email: "one@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandMulti{id: 2, name: "newname", email: "oNe@EXamPLE.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted
      assert p.response == {:error, :validation_failure, [{:email, "has already been taken"}]}
    end

    test "halt if both fields value are not unique" do
      cmd = %TestCommandMulti{id: 1, name: "NewName", email: "one@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandMulti{id: 2, name: "NewName", email: "oNe@EXamPLE.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted

      assert p.response ==
               {:error, :validation_failure,
                [{:email, "has already been taken"}, {:name, "has already been taken"}]}
    end

    test "halt and release 'name' if the 'email' field value is not unique" do
      cmd = %TestCommandMulti{id: 1, name: "NewName", email: "one@example.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
      refute p.response

      #
      cmd = %TestCommandMulti{id: 2, name: "OtherName", email: "oNe@EXamPLE.com"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted

      assert p.response ==
               {:error, :validation_failure, [{:email, "has already been taken"}]}

      cmd = %TestCommandSimple{id: 3, name: "OtherName"}
      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end
  end

  describe "Uniqueness middleware, TestCommandMultiConcat should" do
    @describetag :unit

    test "continue if both fields values are unique" do
      cmd = %TestCommandMultiConcat{
        id: 1,
        name: "NewName",
        email: "one@example.com",
        description: "one"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      #
      cmd = %TestCommandMultiConcat{
        id: 2,
        name: "newname",
        email: "another@example.com",
        description: "two"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end

    test "continue if on of the fields value is unique" do
      cmd = %TestCommandMultiConcat{
        id: 1,
        name: "NewName",
        email: "one@example.com",
        description: "one"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      #
      cmd = %TestCommandMultiConcat{
        id: 2,
        name: "newname",
        email: "one@example.com",
        description: "two"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end

    test "halt if both fields value are not unique" do
      cmd = %TestCommandMultiConcat{
        id: 1,
        name: "NewName",
        email: "one@example.com",
        description: "one"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      #
      cmd = %TestCommandMultiConcat{
        id: 2,
        name: "NewName",
        email: "one@example.com",
        description: "two"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted

      assert p.response ==
               {:error, :validation_failure, [{[:name, :email], "not unique"}]}
    end

    test "halt if both fields value are not unique despite email case" do
      cmd = %TestCommandMultiConcat{
        id: 1,
        name: "NewName",
        email: "one@example.com",
        description: "one"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      #
      cmd = %TestCommandMultiConcat{
        id: 2,
        name: "NewName",
        email: "oNe@EXamPLE.com",
        description: "two"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted

      assert p.response ==
               {:error, :validation_failure, [{[:name, :email], "not unique"}]}
    end

    test "halt and release composit fields value if the 'description' field value is not unique" do
      cmd = %TestCommandMultiConcat{
        id: 1,
        name: "NewName",
        email: "one@example.com",
        description: "same description"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted

      #
      cmd = %TestCommandMultiConcat{
        id: 2,
        name: "OtherName",
        email: "other@example.com",
        description: "same description"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: true}
      assert p.halted

      assert p.response ==
               {:error, :validation_failure, [{:description, "not unique"}]}

      #
      cmd = %TestCommandMultiConcat{
        id: 3,
        name: "OtherName",
        email: "other@example.com",
        description: "another description"
      }

      p = Uniqueness.before_dispatch(%Pipeline{command: cmd})
      # %Pipeline{halted: false}
      refute p.halted
    end
  end
end
