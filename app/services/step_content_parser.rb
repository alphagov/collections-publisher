class StepContentParser
  # it matches the following:
  # * [Link text](url) context
  # - [Link text](url) context
  # * A bullet point without a link
  # - A bullet point without a link
  BULLETED_LIST_REGEX = /^[*-]\s(\[.+\]\(.+\))?.*$/

  # it matches [Link text](url)context
  LIST_REGEX = /^\[.+\]\(.+\).*$/

  # matches [Link text](url)
  LINK_REGEX = /\[[^\[\]]+\]\(([^)]+)/

  GOVUK_DOMAIN_REGEX = /^(https?:\/\/)?(www\.)?gov\.uk\//

  def parse(step_text)
    sections = step_text.rstrip.delete("\r").split("\n\n").map do |section|
      section.lines.map(&:chomp)
    end

    sections.map do |section|
      if standard_list?(section)
        {
          "type": "list",
          "contents": link_content(section),
        }
      elsif bulleted_list?(section)
        {
          "type": "list",
          "style": "choice",
          "contents": link_content(section),
        }
      else
        {
          "type": "paragraph",
          "text": section.join,
        }
      end
    end
  end

  def base_paths(step_text)
    relative_paths(step_text).map { |path| safely_parse_path(path) }.compact
  end

  def all_paths(step_text)
    external_links(step_text) + internal_links(step_text)
  end

private

  def safely_parse_path(path)
    uri = URI.parse(path)
    uri.path
  rescue URI::InvalidURIError
    nil
  end

  def relative_paths(content)
    all_links_in_content(content)
      .map { |url| strip_govuk_prefix(url) }
      .select { |href| href.match(/^\/[a-z0-9]+.*/i) }
  end

  def external_links(content)
    all_links_in_content(content).reject { |href| href.match?(GOVUK_DOMAIN_REGEX) } - relative_paths(content)
  end

  def internal_links(content)
    relative_paths(content).map { |path| prefix_govuk(path) }
  end

  def all_links_in_content(content)
    content.scan(LINK_REGEX).flatten
  end

  def prefix_govuk(path_to_prefix)
    "https://www.gov.uk#{path_to_prefix}"
  end

  def strip_govuk_prefix(url)
    url.sub(GOVUK_DOMAIN_REGEX, "/")
  end

  def standard_list?(section)
    section.all? { |line| line =~ LIST_REGEX }
  end

  def bulleted_list?(section)
    section.all? { |line| line =~ BULLETED_LIST_REGEX }
  end

  def link_content(section)
    section.map do |line|
      payload = {}
      if /\[(?<text>.+)\]\((?<href>.+)\)(?<context>.*)$/ =~ line && safely_parse_path(href)
        payload = {
          "text": text,
          "href": href,
        }
        payload[:context] = context.strip if context.present?
      else
        payload[:text] = line[2..]
      end
      payload
    end
  end
end
