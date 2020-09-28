module CoronavirusPages
  class SubSectionProcessor
    def self.call(*args)
      new(*args).output
    end

    attr_reader :sub_sections, :featured_link

    def initialize(sub_sections)
      @sub_sections = [sub_sections].flatten
      @featured_link = nil
    end

    def output
      process
      {
        content: output_array.join("\n"),
        featured_link: featured_link,
      }
    end

    def output_array
      @output_array ||= []
    end

    def add_string(text)
      output_array << text
    end

    def add_featured_link(url)
      @featured_link = url
    end

    def process
      sub_sections.each do |sub_section|
        add_string("####{sub_section['title']}") if sub_section["title"].present?
        sub_section["list"].each do |item|
          add_string "[#{item['label']}](#{remove_priority_taxon_param(item['url'])})"
          add_featured_link(item["url"]) if item["featured_link"]
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
