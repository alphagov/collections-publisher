# frozen_string_literal: true

class Coronavirus::SubSectionJsonPresenter
  attr_reader :sub_section, :priority_taxon

  def initialize(sub_section, priority_taxon = nil)
    @sub_section = sub_section
    @priority_taxon = priority_taxon
  end

  def output
    @output ||=
      {
        title: sub_section.title,
        sub_heading: sub_section.sub_heading,
        sub_sections: sub_sections,
      }
  end

private

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
    {
      label: label,
      url: append_priority_taxon_query_param(url),
    }
  end

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
