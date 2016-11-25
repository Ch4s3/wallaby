defmodule Wallaby.StatelessQuery do
  defstruct method: nil,
            selector: nil,
            html_validation: nil,
            conditions: [],
            filters: [],
            result: []

  @type method :: :css
                | :xpath
                | :link
                | :button
                | :fillable_field
                | :checkbox
                | :radio_button
                | :option
                | :select
                | :file_field

  alias __MODULE__
  alias Wallaby.XPath

  def css(selector, opts \\ []) do
    %StatelessQuery{
      method: :css,
      selector: selector,
      conditions: build_conditions(opts),
    }
  end

  def xpath(selector, opts \\ []) do
    %StatelessQuery{
      method: :xpath,
      selector: selector,
      conditions: build_conditions(opts)
    }
  end

  def text(selector, opts \\ []) do
    %StatelessQuery{
      method: :text,
      selector: selector,
      conditions: build_conditions(opts)
    }
  end

  def fillable_field(selector, opts) do
    %StatelessQuery{
      method: :fillable_field,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :bad_label,
    }
  end

  def radio_button(selector, opts) do
    %StatelessQuery{
      method: :radio_button,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :bad_label,
    }
  end

  def checkbox(selector, opts) do
    %StatelessQuery{
      method: :checkbox,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :bad_label,
    }
  end

  def select(selector, opts) do
    %StatelessQuery{
      method: :select,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :bad_label,
    }
  end

  def option(selector, opts) do
    %StatelessQuery{
      method: :option,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :bad_label,
    }
  end

  def button(selector, opts \\ []) do
    %StatelessQuery{
      method: :button,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :button_type,
    }
  end

  def link(selector, opts) do
    %StatelessQuery{
      method: :link,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :bad_label,
    }
  end

  def file_field(selector, opts) do
    %StatelessQuery{
      method: :file_field,
      selector: selector,
      conditions: build_conditions(opts),
      html_validation: :bad_label,
    }
  end

  def validate(query) do
    # TODO: This should be handled with xpath if we avoid throwing the error.
    if !StatelessQuery.visible?(query) && StatelessQuery.inner_text(query) do
      {:error, :cannot_set_text_with_invisible_elements}
    else
      {:ok, query}
    end
  end

  def compile(%{method: :css, selector: selector}), do: {:css, selector}
  def compile(%{method: :xpath, selector: selector}), do: {:xpath, selector}
  def compile(%{method: :link, selector: selector}), do: {:xpath, XPath.link(selector)}
  def compile(%{method: :button, selector: selector}), do: {:xpath, XPath.button(selector)}
  def compile(%{method: :fillable_field, selector: selector}), do: {:xpath, XPath.fillable_field(selector)}
  def compile(%{method: :checkbox, selector: selector}), do: {:xpath, XPath.checkbox(selector)}
  def compile(%{method: :radio_button, selector: selector}), do: {:xpath, XPath.radio_button(selector)}
  def compile(%{method: :option, selector: selector}), do: {:xpath, XPath.option(selector)}
  def compile(%{method: :select, selector: selector}), do: {:xpath, XPath.select(selector)}
  def compile(%{method: :file_field, selector: selector}), do: {:xpath, XPath.file_field(selector)}
  def compile(%{method: :text, selector: selector}), do: {:xpath, XPath.text(selector)}

  def visible?(%StatelessQuery{conditions: conditions}) do
    Keyword.get(conditions, :visible)
  end

  def count(%StatelessQuery{conditions: conditions}) do
    Keyword.get(conditions, :count)
  end

  def inner_text(%StatelessQuery{conditions: conditions}) do
    Keyword.get(conditions, :text)
  end

  def result(query) do
    cond do
      count(query) == 1 ->
        [element] = query.result
        element
      true ->
        query.result
    end
  end

  def matches_count?(%{conditions: conditions}, count) do
    cond do
      conditions[:count] == :any ->
        count > 0

      conditions[:count] ->
        conditions[:count] == count

      true ->
        !(conditions[:minimum] && conditions[:minimum] > count) &&
        !(conditions[:maximum] && conditions[:maximum] < count)
    end
  end

  defp build_conditions(opts) do
    opts
    |> add_visibility
    |> add_text
    |> add_count
  end

  defp add_visibility(opts) do
    Keyword.put_new(opts, :visible, true)
  end

  defp add_text(opts) do
    Keyword.put_new(opts, :text, nil)
  end

  defp add_count(opts) do
    cond do
      opts[:count] == nil && opts[:minimum] == nil && opts[:maximum] == nil ->
        Keyword.put(opts, :count, 1)
      true ->
        opts
        |> Keyword.put_new(:count, opts[:count])
        |> Keyword.put_new(:minimum, opts[:minimum])
        |> Keyword.put_new(:maximum, opts[:maximum])
    end
  end
end

