require "rails_helper"

RSpec.describe "Autocomplete component", type: :view do
  it "should not render when no data is given" do
    assert_empty render_component({})
  end

  it "should not render when only a name is provided" do
    assert_empty render_component(name: "foo")
  end

  it "should not render when only a label is provided" do
    assert_empty render_component(label: { text: "foo" })
  end

  it "should generate a randomised id if no id provided" do
    render_component(name: "foo", label: { text: "bar" })

    assert_select ".app-c-autocomplete", count: 1
    random_id = nil
    assert_select ".app-c-autocomplete label", count: 1, text: "bar" do |label|
      random_id = label[0]["for"]
    end
    assert_select ".app-c-autocomplete input[name='foo'][id='#{random_id}']", count: 1
  end

  it "should render text input when id, name & label provided" do
    render_component(
      name: "foo",
      label: { text: "bar" },
      id: "baz",
    )

    assert_select ".app-c-autocomplete", count: 1
    assert_select ".app-c-autocomplete label[for='baz']", count: 1, text: "bar"
    assert_select ".app-c-autocomplete input[name='foo'][id='baz']", count: 1
  end

  it "renders datalist element associated with text input when options provided" do
    render_component(
      id: "basic-autocomplete",
      name: "foo",
      label: { text: "Countries" },
      input: {
        options: ["United Kingdom", "United States"],
      },
    )

    assert_select ".govuk-label", text: "Countries", for: "basic-autocomplete"
    assert_select ".app-c-autocomplete input[name='foo'][id='basic-autocomplete'][list='basic-autocomplete-list']", count: 1
    assert_select "datalist#basic-autocomplete-list", count: 1
    assert_select "datalist#basic-autocomplete-list option[value='United Kingdom']", count: 1
    assert_select "datalist#basic-autocomplete-list option[value='United States']", count: 1
  end

  it "renders a default value if provided" do
    render_component(
      id: "foo",
      name: "foo",
      label: { text: "Countries" },
      input: {
        options: ["United Kingdom", "United States"],
        value: "Spain",
      },
    )

    assert_select ".app-c-autocomplete input[value='Spain'][name='foo'][id='foo'][list='foo-list']", count: 1
    assert_select "datalist#foo-list option[value='United Kingdom']", count: 1
    assert_select "datalist#foo-list option[value='United States']", count: 1
    assert_select "datalist#foo-list option[value='Spain']", count: 0
  end

  it "renders error messages if passed to the component" do
    render_component(
      id: "foo",
      name: "foo",
      label: { text: "Label" },
      error_items: [
        { text: "Something wrong with A" },
        { text: "Also something wrong with B" },
      ],
    )

    assert_select ".app-c-autocomplete .gem-c-error-message", count: 1 do |error|
      error_message = error[0].text
      expect(error_message).to include "Something wrong with A"
      expect(error_message).to include "Also something wrong with B"
    end
  end

  def render_component(arguments)
    render partial: "components/autocomplete", locals: arguments
  end
end
