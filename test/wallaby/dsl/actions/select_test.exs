defmodule Wallaby.Actions.SelectTest do
  use Wallaby.SessionCase, async: true

  setup %{session: session} do
    page =
      session
      |> visit("select_boxes.html")

    {:ok, page: page}
  end

  test "choosing an option from a select box by id", %{page: page} do
    refute find(page, "#select-option-2") |> Element.selected?

    page
    |> select("select-box", option: "Option 2")

    assert find(page, "#select-option-2") |> Element.selected?
  end

  test "choosing an option from a select box by name", %{page: page} do
    refute find(page, "#select-option-5") |> Element.selected?

    page
    |> select("my-select", option: "Option 2")

    assert find(page, "#select-option-5") |> Element.selected?
  end

  test "choosing an option from a select box by label", %{page: page} do
    refute find(page, "#select-option-5") |> Element.selected?

    page
    |> select("My Select", option: "Option 2")

    assert find(page, "#select-option-5") |> Element.selected?
  end

  test "choosing an option from a select box by label when for is id", %{page: page} do
    refute find(page, "#select-option-2") |> Element.selected?

    page
    |> select("Select With ID", option: "Option 2")

    assert find(page, "#select-option-2") |> Element.selected?
  end

  test "throw an error if a label exists but does not have a for attribute", %{page: page} do
    assert_raise Wallaby.QueryError, fn ->
      select(page, "Select with bad label", option: "Option")
    end
  end

  test "waits until the select appears", %{session: session} do
    page =
      session
      |> visit("forms.html")

    assert select(page, "Hidden Select", option: "Option")
  end

  test "escapes quotes", %{page: page} do
    assert select(page, "I'm a select", option: "I'm an option")
  end
end
