# frozen_string_literal: true

class SubSectionJsonPresenter
  HEADER_PATTERN = PatternMaker.call(
    "starts_with hashes then perhaps_spaces then capture(title) and nothing_else",
    hashes: "#+",
    title: '\w.+',
  )

  LINK_PATTERN = PatternMaker.call(
    "starts_with perhaps_spaces within(sq_brackets,capture(label)) then perhaps_spaces and within(brackets,capture(url))",
    label: '\s*\w.+',
    url: '\s*(\b(https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\s*',
  )
  # Url pattern from https://stackoverflow.com/a/163684/1014251

  attr_reader :sub_section, :priority_taxon

  def initialize(sub_section, priority_taxon = nil)
    @sub_section = sub_section
    @priority_taxon = priority_taxon
  end

  delegate :title, to: :sub_section

  def output
    @output ||=
      {
        title: title,
        sub_sections: sub_sections,
      }

    if @sub_section.featured_link.present? && !link_set_as_featured?
      errors << "Featured link does not exist in accordion content"
    end

    @output
  end

  def errors
    @errors ||= []
  end

  def success?
    output
    errors.empty?
  end

  def sub_sections
    content_groups.map { |content_group| sub_section_hash_from_content_group(content_group) }
  end

  def link_set_as_featured?
    featured_links = @output[:sub_sections].flat_map do |section|
      section[:list].map { |item| item[:featured_link] }
    end

    featured_links.any?
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
    content_group.each_with_object({ title: nil }) do |line, hash|
      if is_header?(line)
        title = HEADER_PATTERN.match(line).named_captures["title"]
        hash[:title] = title
      elsif is_link?(line)
        hash[:list] ||= []
        hash[:list] << build_link(line)
      else
        errors << "Unable to parse markdown: '#{line}'"
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
    elsif @sub_section.featured_link == link[:url]
      link[:description] = description_for_featured_link(link[:url])
      link[:featured_link] = true
    end
    append_priority_taxon_query_param(link)
  end

  def description_from_raw_content(url)
    raw_content_url = subtopic_paths[url]
    raw_content = YamlFetcher.new(raw_content_url).body_as_hash
    raw_content.dig("content", "meta_description")
  end

  def description_for_featured_link(base_path)
    return if URI.parse(base_path).absolute?

    content_item(base_path)["description"]
  end

  def content_item(base_path)
    content_id = GdsApi.publishing_api.lookup_content_id(base_path: base_path)
    GdsApi.publishing_api.get_content(content_id)
  end

  def subtopic_paths
    @subtopic_paths ||= Coronavirus::CoronavirusPage.subtopic_pages.pluck(:base_path, :raw_content_url).to_h
  end

  def append_priority_taxon_query_param(link)
    return link if priority_taxon.blank?

    uri = Addressable::URI.parse(link[:url])
    query_params = { "priority-taxon" => priority_taxon }

    uri.query_values = (uri.query_values || {}).merge(query_params)
    link[:url] = uri.to_s
    link
  end
end
