defmodule Wallaby.BrowserTest do
  use Wallaby.SessionCase, async: true

  alias Wallaby.StatelessQuery

  describe "has?/2" do
    test "allows css queries", %{session: session} do
      session
      |> visit("/page_1.html")
      |> has?(css(".blue"))
      |> assert
    end

    test "allows text queries", %{session: session} do
      session
      |> visit("/page_1.html")
      |> has?(StatelessQuery.text("Page 1"))
      |> assert
    end
  end
end
