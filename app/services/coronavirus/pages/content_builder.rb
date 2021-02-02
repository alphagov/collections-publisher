module Coronavirus::Pages
  class ContentBuilder
    attr_reader :coronavirus_page, :errors

    def initialize(coronavirus_page)
      @coronavirus_page = coronavirus_page
      @errors = []
    end

    def data
      @data ||= begin
        validate_content
        data = github_data
        data["sections"] = sub_sections_data
        data["announcements"] = announcements_data

        data["timeline"] ||= {}
        data["timeline"]["list"] = timeline_data

        add_live_stream(data)
        data["hidden_search_terms"] = hidden_search_terms
        data
      end
    rescue RestClient::Exception => e
      add_error(e.message)
    end

    def success?
      data
      errors.empty?
    end

    def add_error(error)
      errors << error
      errors.flatten!
    end

    def validate_content
      required_keys =
        type.to_sym == :landing ? required_landing_page_keys : required_hub_page_keys
      missing_keys = (required_keys - github_data.keys)
      add_error("Invalid content - please recheck GitHub and add #{missing_keys.join(', ')}.") if missing_keys.any?
    end

    def type
      coronavirus_page.slug.to_sym
    end

    def required_landing_page_keys
      %w[
        title
        meta_description
        header_section
        announcements_label
        announcements
        nhs_banner
        sections
        topic_section
        notifications
        live_stream
      ]
    end

    def required_hub_page_keys
      %w[
        title
        header_section
        sections
        topic_section
        notifications
      ]
    end

    def github_raw_data
      YamlFetcher.new(coronavirus_page.raw_content_url).body_as_hash
    end

    def github_data
      @github_data ||= github_raw_data["content"]
    end

    def github_live_stream_data
      github_data["live_stream"] || {}
    end

    def sub_sections_data
      coronavirus_page.sub_sections.order(:position).map do |sub_section|
        presenter = Coronavirus::SubSectionJsonPresenter.new(sub_section, coronavirus_page.content_id)
        add_error(presenter.errors) unless presenter.success?
        presenter.output
      end
    end

    def announcements_data
      coronavirus_page.announcements.order(:position).map do |announcement|
        presenter = Coronavirus::AnnouncementJsonPresenter.new(announcement)
        presenter.output
      end
    end

    def timeline_data
      coronavirus_page
        .timeline_entries
        .order(:position)
        .pluck(:heading, :content)
        .map { |(heading, content)| { "heading" => heading, "paragraph" => content } }
    end

    def persisted_live_stream_data
      return {} unless Coronavirus::LiveStream.any?

      live_stream = Coronavirus::LiveStream.last
      {
        "video_url" => live_stream.url,
        "date" => live_stream.formatted_stream_date,
      }
    end

    def add_live_stream(data)
      if coronavirus_page.slug == "landing"
        data["live_stream"] = github_live_stream_data.merge(persisted_live_stream_data)
      end
    end

    def hidden_search_terms
      search_terms_in_sections + search_terms_in_timeline
    end

    def search_terms_in_sections
      sections = sub_sections_data.map do |section|
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

    def search_terms_in_timeline
      return [] if github_data["timeline"].blank?

      timeline = github_data["timeline"]["list"].map do |item|
        [
          item["heading"],
          MarkdownService.new.strip_markdown(item["paragraph"]),
        ]
      end

      timeline.flatten.select(&:present?).uniq
    end
  end
end
