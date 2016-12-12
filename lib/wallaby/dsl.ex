defmodule Wallaby.DSL do
  @moduledoc false

  defmacro __using__([]) do
    quote do
      import Wallaby.StatelessQuery, only: [
        css: 1,
        css: 2,
        xpath: 1,
        xpath: 2,
      ]
      import Wallaby.Browser
    end
  end
end
