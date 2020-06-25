# frozen_string_literal: true

class SubSectionJsonPresenter
  HEADER_PATTERN = PatternMaker.call(
    "starts_with hashes then perhaps_spaces then capture(title) and nothing_else",
    hashes: "#+",
    title: '\w.+',
  )

  LINK_PATTERN = PatternMaker.call(
    "starts_with perhaps_spaces within(brackets,capture(label)) then perhaps_spaces and within(sq_brackets,capture(url))",
    label: '\s*\w.+',
    url: '\s*(\b(https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\s*',
  )
  # Url pattern from https://stackoverflow.com/a/163684/1014251

  attr_reader :sub_section

  def initialize(sub_section)
    @sub_section = sub_section
  end

  delegate :title, to: :sub_section

  def output
    {
      title: title,
      sub_sections: sub_sections,
    }
  end

  def errors
    @errors ||= []
  end

  def sub_sections
    content_groups.map { |content_group| sub_section_hash_from_content_group(content_group) }
  end

  # Groups the sub section content into an array of arrays, such that:
  #   - links and texts are separated and each is put into an inner array
  #   - each title starts a new inner array containing that title as the first element
  #     and then the links between that title and the next title (or the end of the content)
  #   - if there are no titles, all the links go into a single inner array
  def content_groups
    sub_section.content.lines.each_with_object([]) do |line, sections|
      sections << [] if sections.empty? || is_header?(line)
      line.strip!
      sections.last << line
    end
  end

  # Converts:
  #
  #   [header, link, link]
  #
  # into:
  #
  #    {
  #      title: <text from header>,
  #      list: [
  #        {
  #          label: <first link label>,
  #          url: <first link url>
  #        },
  #        {
  #          label: <second link label>,
  #          url: <second link url>
  #        }
  #    {
  def sub_section_hash_from_content_group(content_group)
    content_group.each_with_object({ title: nil }) do |element, hash|
      if is_header?(element)
        title = HEADER_PATTERN.match(element).named_captures["title"]
        hash[:title] = title
      elsif is_link?(element)
        hash[:list] ||= []
        hash[:list] << build_link(element)
      else
        errors << "Unable to parse markdown: '#{element}'"
      end
    end
  end

  def is_header?(text)
    HEADER_PATTERN =~ text
  end

  def is_link?(text)
    LINK_PATTERN =~ text
  end

  def build_link(element)
    link = LINK_PATTERN.match(element).named_captures.symbolize_keys
    link.transform_values!(&:strip)
    if subtopic_paths.keys.include?(link[:url])
      link[:description] = description_from_raw_content(link[:url])
      link[:featured_link] = true
    end
    link
  end

  def description_from_raw_content(url)
    raw_content_url = subtopic_paths[url]
    raw_content = YamlFetcher.new(raw_content_url).body_as_hash
    raw_content.dig("content", "meta_description")
  end

  def subtopic_paths
    @subtopic_paths ||= CoronavirusPage.subtopic_pages.pluck(:base_path, :raw_content_url).to_h
  end
end
