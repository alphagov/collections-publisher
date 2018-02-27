class StepContentParser
  BULLETED_LIST_REGEX = /^\*\s\[.+\]\(.+\).*$/ # to match * [Link text](url)context
  LIST_REGEX = /^\-\s\[.+\]\(.+\).*$/          # to match - [Link text](url)context
  LINK_CAPTURE_REGEX = /\[(.+)\]\((.+)\)(.*)$/ # to capture $1 = "Link text", $2 = "url" $3 = "context" from above

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
        if $3.blank?
          {
            "text": $1,
            "href": $2
          }
        else
          {
            "text": $1,
            "href": $2,
            "context": $3
          }
        end
      end
    end
  end
end
