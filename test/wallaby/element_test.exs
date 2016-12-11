defmodule Wallaby.ElementTest do
  use Wallaby.SessionCase, async: true
  use Wallaby.DSL

  test "can query for multiple elements", %{session: session} do
    elements =
      session
      |> visit("/")
      |> all("a")

    assert length(elements) == 3
  end

  test "queries can be scoped to elements", %{session: session} do
    users =
      session
      |> visit("nesting.html")
      |> find(".dashboard")
      |> find(".users")
      |> all(".user")

    assert Enum.count(users) == 3
    assert List.first(users) |> Element.text == "Chris"
  end

  test "can get text of an element", %{session: session} do
    text =
      session
      |> visit("/")
      |> find("#header")
      |> Element.text()

    assert text == "Test Index"
  end

  test "can get text of an element and its descendants", %{session: session} do
    text =
      session
      |> visit("/")
      |> find("#parent")
      |> Element.text()

    assert text == "The Parent\nThe Child"
  end

  test "has_text?/2 waits for presence of text and returns a bool", %{session: session} do
    element =
    session
      |> visit("wait.html")
      |> find("#container")

    assert has_text?(element, "main")
    refute has_text?(element, "rain")
  end

  test "assert_text/2 waits for presence of text and and returns true if found", %{session: session} do
    element =
    session
      |> visit("wait.html")
      |> find("#container")

    assert assert_text(element, "main")
  end

  test "assert_text/2 will raise an exception for text not found", %{session: session} do
    element =
    session
      |> visit("wait.html")
      |> find("#container")

    assert_raise Wallaby.ExpectationNotMet, "Text 'rain' was not found.", fn ->
      assert_text(element, "rain")
    end
  end

  test "can get attributes of an element", %{session: session} do
    class =
      session
      |> visit("/")
      |> find("body")
      |> Element.attr("class")

    assert class == "bootstrap"
  end

  test "clearing input", %{session: session} do
    element =
      session
      |> visit("forms.html")
      |> find("#name_field")

    fill_in(element, with: "Chris")
    assert has_value?(element, "Chris")

    Element.clear(element)
    refute has_value?(element, "Chris")
    assert has_value?(element, "")
  end

  test "waits for an element to be visible", %{session: session} do
    session
    |> visit("wait.html")

    assert find(session, ".main")
  end

  test "waits for count elements to be visible", %{session: session} do
    session
    |> visit("wait.html")

    assert find(session, ".orange", count: 5) |> length == 5
  end

  test "finding one or more elements", %{session: session} do
    session
    |> visit("page_1.html")

    assert_raise Wallaby.QueryError, fn ->
      find(session, ".not-there")
    end

    assert find(session, "li", count: :any) |> length == 4
  end

  test "has_css/2 returns true if the css is on the page", %{session: session} do
    page =
      session
      |> visit("nesting.html")

    assert has_css?(page, ".user")
  end

  test "has_no_css/2 checks is the css is not on the page", %{session: session} do
    page =
      session
      |> visit("nesting.html")

    assert has_no_css?(page, ".something_else")
  end

  test "has_no_css/2 raises error if the css is found", %{session: session} do
    assert_raise Wallaby.QueryError, fn ->
      session
      |> visit("nesting.html")
      |> has_no_css?(".user")
    end
  end

  test "sending text", %{session: session} do
    session
    |> visit("forms.html")

    session
    |> find("#name_field")
    |> Element.click

    session
    |> send_text("hello")

    assert session |> find("#name_field") |> has_value?("hello")
  end

  test "sending key presses", %{session: session} do
    session
    |> visit("/")

    session
    |> send_keys([:tab, :enter])

    assert find(session, ".blue")
  end

  test "find/2 raises an error if the element is not visible", %{session: session} do
    session
    |> visit("page_1.html")

    assert_raise Wallaby.QueryError, fn ->
      find(session, "#invisible")
    end

    assert find(session, "#visible", count: :any)
    |> length == 1
  end

  describe "visible?/1" do
    setup :visit_page

    test "determines if the element is visible to the user", %{page: page} do
      page
      |> find("#visible")
      |> Element.visible?
      |> assert

      page
      |> find("#invisible", visible: false)
      |> Element.visible?
      |> refute
    end

    test "handles elements that are not on the page", %{page: page} do
      element = find(page, "#off-the-page", visible: false)

      assert Element.visible?(element) == false
    end

    @tag skip: "Unsuported in phantom"
    test "handles obscured elements", %{page: page} do
      element = find(page, "#obscured", visible: false)

      assert Element.visible?(element) == false
    end
  end

  def visit_page(%{session: session}) do
    page =
      session
      |> visit("page_1.html")

    {:ok, page: page}
  end
end
