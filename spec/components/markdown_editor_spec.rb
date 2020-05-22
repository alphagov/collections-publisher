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
end
