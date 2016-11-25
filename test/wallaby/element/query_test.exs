defmodule Wallaby.Element.QueryTest do
  use Wallaby.SessionCase, async: true

  alias Wallaby.Element
  alias Wallaby.Element.Query

  describe "build_query/3" do
    test "assigns the parent of the query" do
      parent = %Element{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [])

      assert query.parent == parent
    end

    test "builds the correct locator" do
      parent = %Element{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [])

      assert query.locator == locator
    end

    test "merges default conditions" do
      parent = %Element{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [])

      assert query.conditions == [visible: true, count: 1]
    end

    test "doesn't override user specified conditions" do
      parent = %Element{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [visible: false, count: :any])

      assert query.conditions == [visible: false, count: :any]
    end

    test "defaults to no errors" do
      parent = %Element{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [visible: false, count: :any])

      assert query.errors == []
    end
  end
end
