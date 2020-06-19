class SubSectionJsonPresenter

  HEADER_PATTERN = PatternMaker.call(
    'starts_with hashes then perhaps_spaces then target(words) and nothing_else'.freeze,
    hashes: '#+'
  )

  attr_reader :sub_section

  def initialize(sub_section)
    @sub_section = sub_section
  end

  delegate :title, to: :sub_section

  def content_sub_sections
    split_at(sub_section.content, HEADER_PATTERN)
  end

  def split_at(text, pattern)
    regex = /#{pattern}/m
    index = regex =~ text

    return [text] if index.nil?

    if index.zero?
      match = regex.match(text)[0]
      remainder = text.delete_prefix(match)
    else
      match = text[0..(index-1)]
      remainder = text[index..-1]
    end
    [match, split_at(remainder, pattern)].flatten.select(&:present?)
  end
end
