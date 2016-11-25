defmodule Wallaby.DSL.Finders.TitleTest do
  use Wallaby.SessionCase, async: true
  use Wallaby.DSL

  test "finding the title", %{session: session} do
    text =
      session
      |> visit("/")
      |> page_title

    assert text == "Test Index"
  end
end
