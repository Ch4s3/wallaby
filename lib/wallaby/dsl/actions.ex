defmodule Wallaby.DSL.Actions do
  @moduledoc ~S"""
  Provides the action DSL.

  Actions are used to interact with form elements. They follow the same
  conventions as Wallaby.StatelessQuery. Form elements can be found based on
  their id, name, or label text:

  ```html
  <label for="first_name">
    First Name
  </label>
  <input id="user_first_name" type="text" name="first_name">
  ```

  ```
  fill_in(page, "First Name", with: "Grace")
  fill_in(page, "first_name", with: "Grace")
  fill_in(page, "user_first_name", with: "Grace")
  ```

  Note that the id selector does not need the `#`. This makes it easier to use
  with the ids generated by phoenix form helpers.

  There are several helpers for different interacting with different form elements.

  ```
  fill_in(page, "First Name", with: "Chris")
  choose(page, "Radio Button 1")
  check(page, "Checkbox")
  uncheck(page, "Checkbox")
  select(page, "My Awesome Select", option: "Option 1")
  click_on(page, "Some Button")
  attach_file(page, "Avatar", path: "test/fixtures/avatar.jpg")
  ```

  Actions return their parent element so that they can be chained together:

  ```
  page
  |> find(".signup-form")
  |> fill_in("Name", with: "Grace Hopper")
  |> fill_in("Email", with: "grace@hopper.com")
  |> click_on("Submit")
  ```
  """
end
