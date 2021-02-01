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
        Coronavirus::CoronavirusPage.find_or_create_by!(slug: slug) do |coronavirus_page|
          coronavirus_page.attributes = coronavirus_page_attributes
        end
    end

    def sections_heading
      data["sections_heading"]
    end

    def title
      data["title"]
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

    def raw_content_url
      page_config[:raw_content_url]
    end

    def yaml_data
      YamlFetcher.new(raw_content_url).body_as_hash
    end

    def data
      yaml_data["content"]
    end
  end
end
