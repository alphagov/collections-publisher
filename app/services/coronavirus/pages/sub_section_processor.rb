module Coronavirus::Pages
  class SubSectionProcessor
    def self.call(*args)
      new(*args).output
    end

    attr_reader :sub_sections

    def initialize(sub_sections)
      @sub_sections = [sub_sections].flatten
    end

    def output
      process
      {
        content: output_array.join("\n"),
        action_link_url: action_link[:url],
        action_link_content: action_link[:content],
        action_link_summary: action_link[:summary],
      }
    end

  private

    def process
      sub_sections.each do |sub_section|
        add_string("####{sub_section['title']}") if sub_section["title"].present?
        sub_section["list"].each do |item|
          if item["featured_link"]
            add_action_link(item)
          else
            add_string "[#{item['label']}](#{remove_priority_taxon_param(item['url'])})"
          end
        end
      end
    end

    def add_string(text)
      output_array << text
    end

    def output_array
      @output_array ||= []
    end

    def add_action_link(item)
      action_link[:url] = remove_priority_taxon_param(item["url"])
      action_link[:content] = item["label"]
      action_link[:summary] = item["description"]
    end

    def action_link
      @action_link ||= {}
    end

    def remove_priority_taxon_param(url)
      uri = Addressable::URI.parse(url)
      uri.query_values = uri.query_values&.except("priority-taxon")
      uri.normalize.to_s
    end
  end
end
