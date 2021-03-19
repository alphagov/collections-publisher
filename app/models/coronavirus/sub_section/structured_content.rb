class Coronavirus::SubSection::StructuredContent
  HEADER_PATTERN = PatternMaker.call(
    "starts_with hashes then perhaps_spaces then capture(text) and nothing_else",
    hashes: "#+",
    text: '\w.+',
  )

  LINK_PATTERN = PatternMaker.call(
    "starts_with perhaps_spaces within(sq_brackets,capture(label)) then perhaps_spaces and within(brackets,capture(url))",
    label: '\s*\w.+',
    url: '\s*(\b(https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\s*',
  )

  Header = Struct.new(:text)
  Link = Struct.new(:label, :url)

  attr_reader :items

  def self.error_lines(raw_content)
    return [] unless raw_content

    raw_content.lines.filter_map do |line|
      stripped = line.strip
      next if stripped.empty?

      stripped if HEADER_PATTERN.match(stripped).blank? && LINK_PATTERN.match(stripped).blank?
    end
  end

  def self.parseable?(raw_content)
    raw_content.present? && error_lines(raw_content).empty?
  end

  def self.parse(raw_content)
    items = raw_content.lines.filter_map do |line|
      header_match = HEADER_PATTERN.match(line.strip)
      link_match = LINK_PATTERN.match(line.strip)

      if header_match
        Header.new(header_match[:text])
      elsif link_match
        Link.new(link_match[:label], link_match[:url])
      end
    end

    new(items)
  end

  def initialize(items)
    @items = items
  end

  def links
    items.select { |i| i.is_a?(Link) }
  end
end
