module Coronavirus::Pages
  class SectionsPresenter
    attr_reader :data
    def initialize(data)
      @data = [data].flatten
    end

    def output
      data.map do |section|
        converter(section)
      end
    end

    def converter(hash)
      sub_section_data = SubSectionProcessor.call(hash["sub_sections"])

      {
        "title": hash["title"],
        "content": sub_section_data[:content],
        "action_link_url": sub_section_data[:action_link_url],
        "action_link_content": sub_section_data[:action_link_content],
        "action_link_summary": sub_section_data[:action_link_summary],
      }
    end
  end
end
