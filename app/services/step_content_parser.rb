class StepContentParser
  BULLETED_LIST_REGEX = /^[\*\-]\s\[.+\]\(.+\).*$/ # to match * [Link text](url)context
  LIST_REGEX = /^\[.+\]\(.+\).*$/                  # to match [Link text](url)context

  def parse(step_text)
    sections = step_text.split("\n\n").map do |section|
      section.lines.map(&:chomp)
    end

    sections.map do |section|
      if standard_list?(section)
        {
          "type": "list",
          "contents": link_content(section)
        }
      elsif bulleted_list?(section)
        {
          "type": "list",
          "style": "choice",
          "contents": link_content(section)
        }
      else
        {
          "type": "paragraph",
          "text": section.join
        }
      end
    end
  end

private

  def standard_list?(section)
    section.all? { |line| line =~ LIST_REGEX }
  end

  def bulleted_list?(section)
    section.all? { |line| line =~ BULLETED_LIST_REGEX }
  end

  def link_content(section)
    section.map do |line|
      if /\[(?<text>(.+))\]\((?<href>(.+))\)((?<context>.*))$/ =~ line
        payload = {
          "text": text,
          "href": href
        }

        payload[:context] = context unless context.blank?
        payload
      end
    end
  end
end
