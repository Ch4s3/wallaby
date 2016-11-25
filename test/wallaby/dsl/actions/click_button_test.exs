defmodule Wallaby.DSL.Actions.ClickButtonTest do
  use Wallaby.SessionCase, async: true

  alias Wallaby.StatelessQuery

  setup %{session: session} do
    page =
      session
      |> visit("forms.html")

    {:ok, page: page}
  end

  test "clicking button with no type via button text (submits form)", %{page: page} do
    current_url =
      page
      |> click_button("Submit button")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking button with no type via name (submits form)", %{page: page} do
    current_url =
      page
      |> click_button("button-no-type")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking button with no type via id (submits form)", %{page: page} do
    current_url =
      page
      |> click_button("button-no-type-id")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking button type[submit] via button text (submits form)", %{page: page} do
    current_url =
      page
      |> click_button("Submit button")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking button type[submit] via name (submits form)", %{page: page} do
    current_url =
      page
      |> click_button("button-submit")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking button type[submit] via id (submits form)", %{page: page} do
    current_url =
      page
      |> click_button("button-submit-id")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking button type[button] via button text (resets input via JS)", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "Button button")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking button type[button] via name (resets input via JS)", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "button-button")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking button type[button] via id (resets input via JS)", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "button-button-id")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking button type[reset] via button text resets form", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "Reset button")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking button type[reset] via name resets form", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "button-reset")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking button type[reset] via id resets form", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "button-reset-id")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking input type[submit] via button text submits form", %{page: page} do
    current_url =
      page
      |> click_button("Submit input")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking input type[submit] via name submits form", %{page: page} do
    current_url =
      page
      |> click_button("input-submit")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking input type[submit] via id submits form", %{page: page} do
    current_url =
      page
      |> click_button("input-submit-id")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking input type[button] via button text resets input via JS", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "Button input")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking input type[button] via name resets input via JS", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "input-button")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking input type[button] via id resets input via JS", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "input-button-id")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking input type[reset] via button text resets form", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "Reset input")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking input type[reset] via name resets form", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "input-reset")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking input type[reset] via id resets form", %{page: page} do
    page
    |> fill_in("name_field", with: "Erlich Bachman")

    assert find(page, "#name_field") |> has_value?("Erlich Bachman")

    click_button(page, "input-reset-id")

    assert find(page, "#name_field") |> has_value?("")
  end

  test "clicking input type[image] via name submits form", %{page: page} do
    current_url =
      page
      |> click_button("input-image")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "clicking input type[image] via id submits form", %{page: page} do
    current_url =
      page
      |> click_button("input-image-id")
      |> get_current_url

    assert current_url == "http://localhost:#{URI.parse(current_url).port}/index.html"
  end

  test "waits until the button appears", %{page: page} do
    assert click_on(page, "Hidden Button")
  end

  test "throws an error if the button does not include a valid type attribute", %{page: page} do
    msg = Wallaby.QueryError.error_message(
      :button_with_bad_type,
      %{method: :button, selector: "button with bad type"})
    assert_raise Wallaby.QueryError, msg, fn ->
      click_button(page, "button with bad type", [])
    end
  end

  test "throws an error if clicking on an input with no type", %{page: page} do
    msg = Wallaby.QueryError.error_message(
      :not_found,
      %{method: :button, selector: "input-no-type",
       conditions: [count: 1, visible: true]})

    assert_raise Wallaby.QueryError, msg, fn ->
      click_button(page, "input-no-type", [])
    end
  end

  @tag :focus
  test "throws an error if the button cannot be found on the page", %{page: page} do
    msg =
      Wallaby.QueryError.error_message(:not_found,
       StatelessQuery.button("unfound button", count: 1, visible: true))

    assert_raise Wallaby.QueryError, msg, fn ->
      click_button(page, "unfound button", [])
    end
  end

  test "escapes quotes", %{page: page} do
    assert click_on(page, "I'm a button")
  end
end
