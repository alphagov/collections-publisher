# frozen_string_literal: true

class Coronavirus::SubSectionJsonPresenter
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
  end

  def sub_sections
    sub_section.structured_content.items.each_with_object([]) do |item, memo|
      case item
      when Coronavirus::SubSection::StructuredContent::Link
        if memo.empty?
          memo << { title: nil, list: [build_link(item.label, item.url)] }
        else
          memo.last[:list] << build_link(item.label, item.url)
        end
      when Coronavirus::SubSection::StructuredContent::Header
        memo << { title: item.text, list: [] }
      end
    end
  end

  def build_link(label, url)
    link = { label: label, url: url }
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
    @subtopic_paths ||= Coronavirus::Page.subtopic_pages.pluck(:base_path, :raw_content_url).to_h
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
