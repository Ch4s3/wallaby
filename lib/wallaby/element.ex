defmodule Wallaby.Element do
  @moduledoc """
  Common functionality for interacting with DOM elements.
  """

  defstruct [:url, :session_url, :parent, :id, screenshots: []]

  @type url :: String.t
  @type query :: String.t
  @type locator :: Session.t | t
  @type t :: %__MODULE__{
    session_url: url,
    url: url,
    id: String.t,
    screenshots: list,
  }

  alias __MODULE__
  alias Wallaby.Phantom.Driver
  alias Wallaby.Session
  alias Wallaby.Element.Query

  @doc """
  Sets the value of an element.
  """
  def set_value(element, value) do
    {:ok, value} = Driver.set_value(element, value)
  end

  @doc """
  Clears an input field. Input elements are looked up by id, label text, or name.
  The element can also be passed in directly.
  """
  @spec clear(Element.t) :: Session.t

  def clear(element) do
    {:ok, _} = Driver.clear(element)
    element
  end

  @doc """
  Clicks a element.
  """
  @spec click(t) :: Session.t

  def click(element) do
    Driver.click(element)
    element
  end

  def check(%Element{}=element) do
    unless Element.checked?(element) do
      Element.click(element)
    end
    element
  end

  def uncheck(%Element{}=element) do
    if checked?(element) do
      click(element)
    end
    element
  end

  @doc """
  Gets the Element's text value.
  """
  @spec text(t) :: String.t

  def text(element) do
    case Driver.text(element) do
      {:ok, text} ->
        text
      {:error, :stale_reference_error} ->
        raise Wallaby.StaleReferenceException
    end
  end

  @doc """
  Gets the value of the elements attribute.
  """
  @spec attr(t, String.t) :: String.t | nil

  def attr(element, name) do
    {:ok, attribute} = Driver.attribute(element, name)
    attribute
  end

  @doc """
  Gets the selected value of the element.

  For Checkboxes and Radio buttons it returns the selected option.
  """
  @spec selected(t) :: any()

  def selected(element) do
    {:ok, value} = Driver.selected(element)
    value
  end

  @doc """
  Checks if the element has been selected.
  """
  @spec checked?(t) :: boolean()

  def checked?(%Element{}=element) do
    selected(element) == true
  end

  @doc """
  Checks if the element has been selected. Alias for checked?(element)
  """
  @spec selected?(t) :: boolean()

  def selected?(%Element{}=element) do
    checked?(element)
  end

  @doc """
  Checks if the element is visible on the page
  """
  @spec visible?(t) :: boolean()

  def visible?(%Element{}=element) do
    {:ok, displayed} = Driver.displayed(element)
    displayed
  end
end
