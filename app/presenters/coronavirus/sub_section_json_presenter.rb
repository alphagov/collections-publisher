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
    sub_sections = [build_action_link].compact
    sub_sections += sub_section.structured_content.items.each_with_object([]) do |item, memo|
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
    sub_sections
  end

  def build_link(label, url)
    link = { label: label, url: append_priority_taxon_query_param(url) }
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
    @subtopic_paths ||= Coronavirus::Page.subtopic_pages.pluck(:base_path, :raw_content_url).to_h
  end

private

  def append_priority_taxon_query_param(url)
    return url unless priority_taxon.present? && url.starts_with?("/")

    uri = Addressable::URI.parse(url)
    query_params = { "priority-taxon" => priority_taxon }

    uri.query_values = (uri.query_values || {}).merge(query_params)
    uri.to_s
  end

  def build_action_link
    return if sub_section.action_link_url.blank?

    {
      list: [
        {
          url: append_priority_taxon_query_param(sub_section.action_link_url),
          label: sub_section.action_link_content,
          description: sub_section.action_link_summary,
          featured_link: true,
        },
      ],
      title: nil,
    }
  end
end
