class StepContentParser
  # it matches the following:
  # * [Link text](url) context
  # - [Link text](url) context
  # * A bullet point without a link
  # - A bullet point without a link
  BULLETED_LIST_REGEX = /^[\*\-]\s(\[.+\]\(.+\))?.*$/

  # it matches [Link text](url)context
  LIST_REGEX = /^\[.+\]\(.+\).*$/

  def parse(step_text)
    sections = step_text.gsub("\r", "").split("\n\n").map do |section|
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
      if line.scan(/\[/).empty?
        { "text": line[2..-1] }
      elsif /\[(?<text>(.+))\]\((?<href>(.+))\)((?<context>.*))$/ =~ line
        payload = {
          "text": text,
          "href": href
        }

        payload[:context] = context.strip unless context.blank?
        payload
      end
    end
  end
end
