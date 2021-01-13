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

  it "renders bullet list toolbar button if bullets is configured" do
    render "components/markdown_editor",
           controls: [:bullets],
           label: {
             text: "Body",
           },
           textarea: {
             name: "markdown-editor",
             id: "markdown-editor",
           }

    assert_select ".app-c-markdown-editor__toolbar-button[title='Bullets']", count: 1
  end

  it "renders heading toolbar buttons if headings is configured" do
    render "components/markdown_editor",
           controls: [:headings],
           label: {
             text: "Body",
           },
           textarea: {
             name: "markdown-editor",
             id: "markdown-editor",
           }

    assert_select ".app-c-markdown-editor__toolbar-button[title='Heading level 2']", count: 1
    assert_select ".app-c-markdown-editor__toolbar-button[title='Heading level 3']", count: 1
  end

  it "renders blockquote toolbar button if blockquote is configured" do
    render "components/markdown_editor",
           controls: [:blockquote],
           label: {
             text: "Body",
           },
           textarea: {
             name: "markdown-editor",
             id: "markdown-editor",
           }

    assert_select ".app-c-markdown-editor__toolbar-button[title='Blockquote']", count: 1
  end

  it "renders numbered list toolbar button if numbered_list is configured" do
    render "components/markdown_editor",
           controls: [:numbered_list],
           label: {
             text: "Body",
           },
           textarea: {
             name: "markdown-editor",
             id: "markdown-editor",
           }

    assert_select ".app-c-markdown-editor__toolbar-button[title='Numbered list']", count: 1
  end

  it "renders error messages if passed to the component" do
    render "components/markdown_editor",
           error_message: "Something is wrong",
           label: {
             text: "Body",
           },
           textarea: {
             name: "markdown-editor",
             id: "markdown-editor",
           }

    assert_select ".govuk-error-message", text: "Error: Something is wrong"
  end
end
