require "action_view"

class MarkdownService
  include ActionView::Helpers::SanitizeHelper

  def strip_markdown(content)
    document = Kramdown::Document.new(content)
    strip_tags(document.to_html).squish
  end
end
