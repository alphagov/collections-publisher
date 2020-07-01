require "rails_helper"

RSpec.describe "Markdown editor", type: :view do
  it "fails to render when no data is given" do
    assert_raises do
      render "components/markdown_editor"
    end
  end

  it "renders a textarea with a label and toolbar" do
    render "components/markdown_editor",
           label: {
             text: "Body",
           },
           textarea: {
             name: "markdown-editor",
             id: "markdown-editor",
           }

    assert_select ".govuk-label[for='markdown-editor']", text: "Body"
    assert_select ".app-c-markdown-editor__toolbar-group[for='markdown-editor']"
    assert_select ".govuk-textarea[id='markdown-editor']"
  end

  it "does not render bullet list toolbar button if hide_bullets_button is true" do
    render "components/markdown_editor",
           hide_bullets_button: true,
           label: {
             text: "Body",
           },
           textarea: {
             name: "markdown-editor",
             id: "markdown-editor",
           }

    assert_select ".app-c-markdown-editor__toolbar-button[title='Bullets']", count: 0
  end
end
