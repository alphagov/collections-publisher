module CoronavirusPages
  class Updater
    attr_reader :slug

    def initialize(slug)
      @slug = slug
    end

    def page
      @page ||=
        CoronavirusPage.find_or_create_by(slug: slug) do |coronavirus_page|
          coronavirus_page.attributes = coronavirus_page_attributes
          coronavirus_page.sub_sections = sub_sections
        end
    end

  private

    def page_config
      CoronavirusPages::Configuration
    end

    def coronavirus_page_attributes
      page_config.page(slug)
    end

    def sub_sections
      parsed_sub_sections.map do |sub_section|
        SubSection.new(sub_section)
      end
    end

    #to do: replace with SectionsParser.new(YamlFetcher.new(raw_content_url).body_as_hash)
    def parsed_sub_sections
      [
        {
          title: "title",
          content: "text"
        }
      ]
    end
  end
end
