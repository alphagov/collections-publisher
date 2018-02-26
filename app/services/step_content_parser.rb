class StepContentParser
  BULLETED_LIST_REGEX = /^\*\s\[.+\]\(.+\)$/ # to match * [Link text](url)
  LIST_REGEX = /^\-\s\[.+\]\(.+\)$/          # to match - [Link text](url)
  LINK_CAPTURE_REGEX = /\[(.+)\]\((.+)\)$/   # to capture $1 = "Link text", $2 = "url" from above

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
      if line =~ LINK_CAPTURE_REGEX
        {
          "text": $1,
          "href": $2
        }
      end
    end
  end
end
