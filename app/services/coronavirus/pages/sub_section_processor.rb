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
        output_array << title_markdown(sub_section["title"]) if sub_section["title"].present?
        sub_section["list"].each do |item|
          if item["featured_link"]
            add_action_link(item["url"], item["label"], item["description"])
          else
            output_array << link_markdown(item["url"], item["label"])
          end
        end
      end
    end

    def output_array
      @output_array ||= []
    end

    def title_markdown(title)
      "####{title}"
    end

    def add_action_link(url, label, description)
      action_link[:url] = remove_priority_taxon_param(url)
      action_link[:content] = label
      action_link[:summary] = description
    end

    def action_link
      @action_link ||= {}
    end

    def link_markdown(url, label)
      link_url = remove_priority_taxon_param(url)
      "[#{label}](#{link_url})"
    end

    def remove_priority_taxon_param(url)
      uri = Addressable::URI.parse(url)
      uri.query_values = uri.query_values&.except("priority-taxon")
      uri.normalize.to_s
    end
  end
end
