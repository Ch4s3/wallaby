defmodule Wallaby.Browser do
  alias Wallaby.Element
  alias Wallaby.Phantom.Driver
  alias Wallaby.StatelessQuery
  alias Wallaby.Session

  @default_max_wait_time 3_000

  def retry(f, start_time \\ current_time) do
    case f.() do
      {:ok, result} ->
        {:ok, result}
      {:error, :stale_reference} ->
        retry(f, start_time)
      {:error, e} ->
        if max_time_exceeded?(start_time) do
          {:error, e}
        else
          retry(f, start_time)
        end
    end
  end

  @doc """
  Finds a specific DOM element on the page based on a css selector. Blocks until
  it either finds the element or until the max time is reached. By default only
  1 element is expected to match the query. If more elements are present then a
  count can be specified. By default only elements that are visible on the page
  are returned.

  Selections can be scoped by providing a Element as the locator for the query.
  """
  def find(parent, css, opts) when is_binary(css) do
    find(parent, StatelessQuery.css(css, opts))
  end
  def find(parent, css) when is_binary(css) do
    find(parent, StatelessQuery.css(css))
  end
  def find(parent, %StatelessQuery{}=query) do
    case execute_query(parent, query) do
      {:ok, query} ->
        StatelessQuery.result(query)
      {:error, e} ->
        if Wallaby.screenshot_on_failure? do
          Session.take_screenshot(parent)
        end

        case validate_html(parent, query) do
          {:ok, _} ->
            raise Wallaby.QueryError, {query, e}
          {:error, html_error} ->
            raise Wallaby.QueryError, {query, html_error}
        end
    end
  end

  defp execute_query(parent, query) do
    retry fn ->
      # TODO: Extract a few pieces of this logic so we dont' recompute them
      with {:ok, query}  <- StatelessQuery.validate(query),
           {method, selector} <- StatelessQuery.compile(query),
           {:ok, elements} <- Driver.find_elements(parent, {method, selector}),
           {:ok, elements} <- validate_visibility(query, elements),
           {:ok, elements} <- validate_text(query, elements),
           {:ok, elements} <- validate_count(query, elements),
       do: {:ok, %StatelessQuery{query | result: elements}}
    end
  end

  @doc """
  Finds all of the DOM elements that match the css selector. If no elements are
  found then an empty list is immediately returned.
  """
  def all(parent, css) when is_binary(css) do
    find(parent, StatelessQuery.css(css, minimum: 0))
  end
  def all(parent, %StatelessQuery{}=query) do
    find(parent, %StatelessQuery{query | conditions: Keyword.merge(query.conditions, [count: nil, minimum: 0])})
  end

  @doc """
  Matches the Element's value with the provided value.
  """
  # @spec has_value?(t, any()) :: boolean()

  def has_value?(%Element{}=element, value) do
    Element.attr(element, "value") == value
  end

  @doc """
  Matches the Element's content with the provided text and raises if not found
  """
  # @spec assert_text(t, String.t) :: boolean()

  def assert_text(%Element{}=element, text) when is_binary(text) do
    cond do
      has?(element, StatelessQuery.text(text)) -> true
      true -> raise Wallaby.ExpectationNotMet, "Text '#{text}' was not found."
    end
  end

  def has?(parent, query) do
    case execute_query(parent, query) do
      {:ok, query} -> true
      {:error, e} -> false
    end
  end

  @doc """
  Matches the Element's content with the provided text
  """
  # @spec has_text?(t, String.t) :: boolean()

  def has_text?(%Element{}=element, text) when is_binary(text) do
    try do
      assert_text(element, text)
    rescue
      _e in Wallaby.ExpectationNotMet -> false
    end
  end

  @doc """
  Searches for CSS on the page.
  """
  # @spec has_css?(locator, String.t) :: boolean()

  def has_css?(parent, css) when is_binary(css) do
    parent
    |> Wallaby.Browser.find(Wallaby.StatelessQuery.css(css, count: :any))
    |> Enum.any?
  end

  @doc """
  Searches for css that should not be on the page
  """
  # @spec has_no_css?(locator, String.t) :: boolean()

  def has_no_css?(parent, css) when is_binary(css) do
    parent
    |> Wallaby.Browser.find(Wallaby.StatelessQuery.css(css, count: 0))
    |> Enum.empty?
  end

  def visit(session, page) do
    Wallaby.Session.visit(session, page)
  end

  defp validate_html(parent, %{html_validation: :button_type}=query) do
    buttons = all(parent, StatelessQuery.css("button", [text: query.selector]))

    cond do
      Enum.any?(buttons) ->
        {:error, :button_with_bad_type}
      true ->
        {:ok, query}
    end
  end
  defp validate_html(parent, %{html_validation: :bad_label}=query) do
    label_query = StatelessQuery.css("label", text: query.selector)
    labels = all(parent, label_query)

    cond do
      Enum.any?(labels, &(missing_for?(&1))) ->
        {:error, :label_with_no_for}
      label=List.first(labels) ->
        {:error, {:label_does_not_find_field, Element.attr(label, "for")}}
      true ->
        {:ok, query}
    end
  end
  defp validate_html(parent, query), do: {:ok, query}

  defp missing_for?(element) do
    Element.attr(element, "for") == nil
  end

  defp validate_visibility(query, elements) do
    visible = StatelessQuery.visible?(query)

    {:ok, Enum.filter(elements, &(Element.visible?(&1) == visible))}
  end

  defp validate_count(query, elements) do
    cond do
      StatelessQuery.matches_count?(query, Enum.count(elements)) ->
        {:ok, elements}
      true ->
        {:error, :not_found}
    end
  end

  defp validate_text(query, elements) do
    text = StatelessQuery.inner_text(query)

    if text do
      {:ok, Enum.filter(elements, &(matching_text?(&1, text)))}
    else
      {:ok, elements}
    end
  end

  defp matching_text?(element, text) do
    case Driver.text(element) do
      {:ok, element_text} ->
        element_text =~ ~r/#{Regex.escape(text)}/
      {:error, _} ->
        false
    end
  end

  defp max_time_exceeded?(start_time) do
    current_time - start_time > max_wait_time
  end

  defp current_time do
    :erlang.monotonic_time(:milli_seconds)
  end

  defp max_wait_time do
    Application.get_env(:wallaby, :max_wait_time, @default_max_wait_time)
  end
end
