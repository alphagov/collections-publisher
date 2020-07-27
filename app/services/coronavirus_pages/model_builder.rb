module CoronavirusPages
  class ModelBuilder
    def self.call(*args)
      new(*args).page
    end

    attr_reader :slug, :action

    def initialize(slug, action = nil)
      @slug = slug
      @action = action
    end

    def page
      @page ||=
        CoronavirusPage.find_or_create_by!(slug: slug) do |coronavirus_page|
          coronavirus_page.attributes = coronavirus_page_attributes
        end
    end

    def discard_changes
      if live_content.any?
        store_live_subsections
        page.update!(state: "published")
      end
    end

    def sections_heading
      data["sections_heading"]
    end

    def title
      data["title"]
    end

  private

    def store_live_subsections
      page.sub_sections.destroy_all
      page.sub_sections = sub_sections
    end

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

    def sub_sections
      sub_section_attributes.each_with_index.map do |attributes, i|
        attributes["position"] = i
        SubSection.new(attributes)
      end
    end

    def sub_section_attributes
      SectionsPresenter.new(data["sections"]).output
    end

    def yaml_data
      YamlFetcher.new(raw_content_url).body_as_hash
    end

    def live_content
      @live_content ||=
        begin
          content = Services.publishing_api.get_content(page.content_id)
          content.to_hash
        rescue GdsApi::HTTPErrorResponse
          {}
        end
    end

    def data
      action == :discard ? live_content["details"] : yaml_data["content"]
    end
  end
end
