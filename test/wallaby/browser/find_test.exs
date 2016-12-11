defmodule Wallaby.Browser.FindTest do
  use Wallaby.SessionCase, async: true

  setup %{session: session} do
    page =
      session
      |> visit("forms.html")

    {:ok, page: page}
  end

  describe "find/3" do
    setup %{session: session} do
      page =
        session
        |> visit("page_1.html")

      {:ok, page: page}
    end

    test "can find an element on a page", %{session: session} do
      element =
        session
        |> find(".blue")

      assert element
    end

    test "throws a not found error if the element could not be found", %{page: page} do
      assert_raise Wallaby.QueryError, ~r/Expected to find/, fn ->
        find(page, css("#not-there"))
      end
    end

    test "throws a not found error if the xpath could not be found", %{page: page} do
      assert_raise Wallaby.QueryError, ~r/Expected (.*) xpath '\/\/test-element'/, fn ->
        find page, xpath("//test-element")
      end
    end

    test "ambiguous queries raise an exception", %{page: page} do
      assert_raise Wallaby.QueryError, ~r/Expected (.*) 1(.*) but 5/, fn ->
        find page, css(".user")
      end
    end

    test "throws errors if element should not be visible", %{page: page} do
      assert_raise Wallaby.QueryError, ~r/invisible/, fn ->
        find(page, "#visible", visible: false)
      end
    end

    test "finds invisible elements", %{page: page} do
      assert find(page, "#invisible", visible: false)
    end

    test "can be scoped with inner text", %{page: page} do
      user1 = find(page, ".user", text: "Chris K.")
      user2 = find(page, ".user", text: "Grace H.")
      assert user1 != user2
    end

    test "can be scoped by inner text when there are multiple elements with text", %{page: page} do
      element = find(page, ".inner-text", text: "Inner Text")
      assert element
    end

    test "scoping with text escapes the text", %{page: page} do
      assert find(page, ".plus-one", text: "+ 1")
    end

    test "scopes can be composed together", %{page: page} do
      assert find(page, ".user", text: "Same User", count: 2)
      assert find(page, ".user", text: "Visible User", visible: true)
      assert find(page, ".invisible-elements", visible: false, count: 3)
    end
  end
end
