defmodule Wallaby.QueryError do
  defexception [:message]

  alias Wallaby.Element.Query

  @doc false
  @spec exception(Query.t) :: Exception.t

  def exception({query, error}) do
    %__MODULE__{message: error_message(error, query)}
  end

  @doc """
  Compose an error message based on the error method and query information
  """
  @spec error_message(atom(), %{}) :: String.t

  def error_message(:not_found, %{selector: selector, method: method, conditions: opts}) do
    msg = "Could not find any #{visibility(opts)} #{method(method)} that matched: '#{selector}'"
    [msg] ++ conditions(opts)
    |> Enum.join(" and ")
  end
  def error_message(:found, %{selector: selector, method: method}) do
    """
    The element with #{method method}: '#{selector}' should not have been found but was
    found.
    """
  end
  def error_message(:ambiguous, %{selector: selector, result: elements, method: method, conditions: opts}) do
    count = Keyword.get(opts, :count)

    """
    The #{method(method)} that matched: '#{selector}' was found but
    the results are ambiguous. It was found #{times(length(elements))} but it
    should have been found #{times(count)}

    If you expect to find the selector #{times(length(elements))} then you
    should include the `count: #{length(elements)}` option in your finder.
    """
  end
  def error_message(:label_with_no_for, %{method: method, selector: selector}) do
    """
    The text '#{selector}' matched a label but the label has no 'for'
    attribute and can't be used to find the correct #{method(method)}.

    You can fix this by including the `for="YOUR_INPUT_ID"` attribute on the
    appropriate label.
    """
  end
  def error_message({:label_does_not_find_field, for_text}, %{method: method, selector: selector}) do
    """
    The text '#{selector}' matched a label but the label's 'for' attribute
    doesn't match the id of any #{method(method)}.

    Make sure that id on your #{method(method)} is `id="#{for_text}"`.
    """
  end
  def error_message(:button_with_bad_type, %{selector: selector}) do
    """
    The text '#{selector}' matched a button but the button has no 'type' attribute.

    You can fix this by including `type="[submit|reset|button|image]"` on the appropriate button.
    """
  end
  def error_message(:button_with_bad_type, %{selector: selector}) do
    """
    The text '#{selector}' matched a button but the button has an invalid 'type' attribute.
    """
  end
  def error_message(:cannot_set_text_with_invisible_elements, _) do
    """
    Cannot set the `text` filter when `visible` is set to `false`.

    Text is based on visible text on the page. This is a limitation of webdriver.
    Since the element isn't visible the text isn't visible. Because of that I 
    can't apply both filters correctly.
    """
  end

  @doc """
  Extracts the selector method from the selector and converts it into a human
  readable format
  """
  @spec method({atom(), any()}) :: String.t

  def method(:css), do: "element with css"
  def method(:select), do: "select"
  def method(:fillable_field), do: "text input or textarea"
  def method(:checkbox), do: "checkbox"
  def method(:radio_button), do: "radio button"
  def method(:link), do: "link"
  def method(:xpath), do: "element with an xpath"
  def method(:button), do: "button"
  def method(:file_field), do: "file field"
  def method(_), do: "element"

  @doc """
  Generates failure conditions based on query conditions.
  """
  @spec conditions(Keyword.t) :: list(String.t)

  def conditions(opts) do
    opts
    |> Keyword.delete(:visible)
    |> Keyword.delete(:count)
    |> Enum.map(&condition/1)
    |> Enum.reject(& &1 == nil)
  end

  @doc """
  Converts a condition into a human readable failure message.
  """
  @spec condition({atom(), String.t}) :: String.t | nil

  def condition({:text, text}) when is_binary(text) do
    "text: '#{text}'"
  end
  def condition(_), do: nil

  @doc """
  Converts the visibilty attribute into a human readable form.
  """
  @spec visibility(Keyword.t) :: String.t

  def visibility(opts) do
    if Keyword.get(opts, :visible) do
      "visible"
    else
      "invisible"
    end
  end

  defp times(1), do: "1 time"
  defp times(count), do: "#{count} times"
end

defmodule Wallaby.ExpectationNotMet do
  defexception [:message]
end

defmodule Wallaby.BadMetadata do
  defexception [:message]
end

defmodule Wallaby.NoBaseUrl do
  defexception [:message]

  def exception(relative_path) do
    msg = """
    You called visit with #{relative_path}, but did not set a base_url.
    Set this in config/test.exs or in test/test_helper.exs:

      Application.put_env(:wallaby, :base_url, "http://localhost:4001")

    If using Phoenix, you can use the url from your endpoint:

      Application.put_env(:wallaby, :base_url, YourApplication.Endpoint.url)
    """

    %__MODULE__{message: msg}
  end
end

defmodule Wallaby.JSError do
  defexception [:message]

  def exception(js_error) do
    msg = """
    There was an uncaught javascript error:

    #{js_error}
    """

    %__MODULE__{message: msg}
  end
end

defmodule Wallaby.StaleReferenceException do
  defexception [:message]

  def exception(_) do
    msg = """
    The element you are trying to reference is stale or no longer attached to the
    DOM. The most likely reason is that it has been removed with Javascript.

    You can typically solve this problem by using `find` to block until the DOM is in a
    stable state.
    """

    %__MODULE__{message: msg}
  end
end

defmodule Wallaby.InvalidSelector do
  defexception [:message]

  def exception(%{"using" => method, "value" => selector}) do
    msg = """
    The #{method} '#{selector}' is invalid.
    """

    %__MODULE__{message: msg}
  end
end
