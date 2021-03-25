module Coronavirus::Pages
  class SubSectionProcessor
    def self.call(*args)
      new(*args).output
    end

    attr_reader :sub_sections, :action_link_url

    def initialize(sub_sections)
      @sub_sections = [sub_sections].flatten
      @action_link_url = nil
    end

    def output
      process
      {
        content: output_array.join("\n"),
        action_link_url: action_link_url,
      }
    end

    def output_array
      @output_array ||= []
    end

    def add_string(text)
      output_array << text
    end

    def add_action_link_url(url)
      @action_link_url = url
    end

    def process
      sub_sections.each do |sub_section|
        add_string("####{sub_section['title']}") if sub_section["title"].present?
        sub_section["list"].each do |item|
          add_string "[#{item['label']}](#{remove_priority_taxon_param(item['url'])})"
          add_action_link_url(item["url"]) if item["featured_link"]
        end
      end
    end

    def remove_priority_taxon_param(url)
      uri = Addressable::URI.parse(url)
      uri.query_values = uri.query_values&.except("priority-taxon")
      uri.normalize.to_s
    end
  end
end
