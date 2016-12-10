defmodule Wallaby.Exceptions.QueryErrorTest do
  use ExUnit.Case, async: true

  import Wallaby.QueryError

  describe "method/1" do
    test "css" do
      assert method(:css) == "element with css"
    end

    test "select" do
      assert method(:select) == "select"
    end

    test "fillable fields" do
      assert method(:fillable_field) == "text input or textarea"
    end

    test "checkboxes" do
      assert method(:checkbox) == "checkbox"
    end

    test "radio buttons" do
      assert method(:radio_button) == "radio button"
    end

    test "link" do
      assert method(:link) == "link"
    end

    test "xpath" do
      assert method(:xpath) == "element with an xpath"
    end

    test "buttons" do
      assert method(:button) == "button"
    end

    test "any unspecified locators" do
      assert method(:random) == "element"
    end

    test "file field" do
      assert method(:file_field) == "file field"
    end
  end

  describe "conditions/1" do
    test "removes visibility and count keys" do
      assert conditions([count: 3, visible: true]) == []
    end
  end

  describe "condition/1" do
    test "text" do
      assert condition({:text, "test"}) == "text: 'test'"
    end

    test "unknown keys" do
      assert condition({:random, "foo"}) == nil
    end
  end

  describe "visibility/1" do
    test "when the visibile key is present and truthy" do
      assert visibility([visible: true]) == "visible"
    end

    test "when the visible key is present and falsy" do
      assert visibility([visible: false]) == "invisible"
    end

    test "when the visible key is not present" do
      assert visibility([]) == "invisible"
    end
  end
end
