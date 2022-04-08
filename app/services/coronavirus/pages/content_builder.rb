module Coronavirus::Pages
  class ContentBuilder
    class GitHubConnectionError < RuntimeError; end

    class GitHubInvalidContentError < RuntimeError; end

    attr_reader :page

    def initialize(page)
      @page = page
    end

    def data
      @data ||= begin
        validate_content
        data = github_data
        data["header_section"] = header_data
        data["sections"] = sub_sections_data

        data["hidden_search_terms"] = hidden_search_terms
        data
      end
    end

    def validate_content
      missing_keys = (required_landing_page_keys - github_data.keys)

      raise GitHubInvalidContentError if missing_keys.any?
    end

    def type
      page.slug.to_sym
    end

    def required_landing_page_keys
      %w[
        title
        meta_description
        sections_heading
        topic_section
        notifications
      ]
    end

    def github_raw_data
      YamlFetcher.new(page.raw_content_url).body_as_hash
    rescue RestClient::Exception
      raise GitHubConnectionError
    end

    def github_data
      @github_data ||= github_raw_data["content"]
    end

    def header_data
      {
        "title" => page.header_title,
        "intro" => page.header_body,
        "link" => {
          "href" => page.header_link_url,
          "link_text" => page.header_link_pre_wrap_text,
          "link_nowrap_text" => page.header_link_post_wrap_text,
        },
      }
    end

    def sub_sections_data
      page.sub_sections.order(:position).map do |sub_section|
        presenter = Coronavirus::SubSectionJsonPresenter.new(sub_section, page.content_id)
        presenter.output
      end
    end

    def hidden_search_terms
      sections = sub_sections_data.map do |section|
        next if section.blank?

        [section[:title], search_terms_in_sub_sections(section[:sub_sections])]
      end

      sections.flatten.select(&:present?).uniq
    end

    def search_terms_in_sub_sections(items)
      items.map do |subsection|
        labels = subsection[:list]&.map do |list_item|
          list_item[:label]
        end

        [subsection[:title], labels]
      end
    end
  end
end
