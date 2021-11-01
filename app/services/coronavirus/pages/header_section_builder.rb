module Coronavirus::Pages
  class HeaderSectionBuilder
    def create_header
      return if header_from_yaml.blank?

      Coronavirus::Page.transaction do
        coronavirus_page.update!(
          header_title: header_from_yaml["title"],
          header_body: header_from_yaml["intro"],
          header_link_url: header_from_yaml["link"]["href"],
          header_link_pre_wrap_text: header_from_yaml["link"]["link_text"],
          header_link_post_wrap_text: header_from_yaml["link"]["link_nowrap_text"],
        )
      end
    end

  private

    def header_from_yaml
      @github_data ||= YamlFetcher.new(coronavirus_page.raw_content_url).body_as_hash
      @github_data.dig("content", "header_section")
    end

    def coronavirus_page
      @coronavirus_page ||= Coronavirus::Page.find_by(slug: "landing")
    end
  end
end
