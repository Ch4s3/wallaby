defmodule Wallaby.SessionTest do
  use Wallaby.SessionCase, async: true
  use Wallaby.DSL

  test "click through to another page", %{session: session} do
    session
    |> visit("")
    |> click_link("Page 1")

    element =
      session
      |> find(".blue")

    assert element
  end

  test "gets the current_url of the session", %{session: session}  do
    current_url =
      session
      |> visit("")
      |> click_link("Page 1")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/page_1.html"
  end

  test "gets the current_path of the session", %{session: session}  do
    current_path =
      session
      |> visit("")
      |> click_link("Page 1")
      |> get_current_path

    assert current_path == "/page_1.html"
  end

  test "manipulating window size", %{session: session} do
    window_size =
      session
      |> visit("/")
      |> set_window_size(1234, 1234)
      |> get_window_size

    assert window_size == %{"height" => 1234, "width" => 1234}
  end

  test "executing scripts with arguments and returning", %{session: session} do
    script = """
      var element = document.createElement("div")
      element.id = "new-element"
      var text = document.createTextNode(arguments[0])
      element.appendChild(text)
      document.body.appendChild(element)
      return arguments[1]
    """

    result =
      session
      |> visit("page_1.html")
      |> execute_script(script, ["now you see me", "return value"])

    assert result == "return value"
    assert session
    |> find("#new-element")
    |> Element.text == "now you see me"
  end
end
