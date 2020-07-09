module CoronavirusPages
  class ModelBuilder
    def self.call(*args)
      new(*args).page
    end

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
      CoronavirusPages::Configuration.page(slug)
    end

    def coronavirus_page_attributes
      page_config.merge(
        sections_title: sections_heading,
        title: title,
      )
    end

    def sections_heading
      yaml_data.dig("content", "sections_heading")
    end

    def title
      yaml_data.dig("content", "title")
    end

    def raw_content_url
      page_config[:raw_content_url]
    end

    def sub_sections
      sub_section_attributes.each_with_index.map do |attributes, i|
        attributes["position"] = i
        SubSection.new(attributes)
      end
    end

    def sub_section_attributes
      SectionsPresenter.new(yaml_data.dig("content", "sections")).output
    end

    def yaml_data
      YamlFetcher.new(raw_content_url).body_as_hash
    end
  end
end
