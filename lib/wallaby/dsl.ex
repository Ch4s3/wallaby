defmodule Wallaby.DSL do
  @moduledoc false

  defmacro __using__([]) do
    quote do
      import Wallaby.StatelessQuery, only: [
        css: 1,
        css: 2,
        xpath: 1,
        xpath: 2,
        text: 1,
        text: 2,
      ]
      import Wallaby.Browser, only: [
        find: 3,
        find: 2,
        all: 2,
        has?: 2,
        has_value?: 2,
        assert_text: 2,
        has_text?: 2,
        has_css?: 2,
        has_no_css?: 2,
      ]
      import Wallaby.Session
      import Wallaby.DSL.Actions

      alias Wallaby.Element
    end
  end
end
