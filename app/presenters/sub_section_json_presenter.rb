# frozen_string_literal: true

class SubSectionJsonPresenter
  HEADER_PATTERN = PatternMaker.call(
    "starts_with hashes then perhaps_spaces then target(title) and nothing_else",
    hashes: "#+",
    title: '\w.+',
  )

  LINK_PATTERN = PatternMaker.call(
    "starts_with within(brackets,target(label)) then within(sq_brackets,target(url))",
    label: '\s*\w.+',
    url: '[\w\/]+',
  )

  attr_reader :sub_section

  def initialize(sub_section)
    @sub_section = sub_section
  end

  delegate :title, to: :sub_section

  def output
    {
      details: {
        sections: [
          {
            title: title,
            sub_sections: sub_sections,
          },
        ],
      },
    }
  end

  def sub_sections
    content_sub_sections.map { |array| sub_section_hash_from_array(array) }
  end

  def content_sub_sections
    sub_section.content.lines.each_with_object([]) do |line, sections|
      sections << [] if sections.empty? || is_header?(line)
      line.strip!
      sections.last << line
    end
  end

  def sub_section_hash_from_array(array)
    array.each_with_object({ title: nil }) do |element, hash|
      if is_header?(element)
        title = HEADER_PATTERN.match(element).named_captures["title"]
        hash[:title] = title
      else
        link = LINK_PATTERN.match(element).named_captures.symbolize_keys
        hash[:list] ||= []
        hash[:list] << link
      end
    end
  end

  def is_header?(text)
    HEADER_PATTERN =~ text
  end
end
