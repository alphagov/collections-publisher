module CoronavirusPages
  class DraftDiscarder
    attr_reader :coronavirus_page

    def initialize(coronavirus_page)
      @coronavirus_page = coronavirus_page
    end

    def call
      return if payload_from_publishing_api.blank?

      Coronavirus::CoronavirusPage.transaction do
        coronavirus_page.update!(state: "published")
        update_announcements
        update_sub_sections
        update_timeline_entries
      end
    end

  private

    def update_announcements
      coronavirus_page.announcements.delete_all
      coronavirus_page.announcements = announcements
    end

    def announcements
      announcements_from_payload.map.with_index do |announcement, index|
        Coronavirus::Announcement.new(
          title: announcement[:text],
          path: announcement[:href],
          published_at: Date.parse(announcement[:published_text]),
          position: index + 1,
        )
      end
    end

    def announcements_from_payload
      payload_from_publishing_api[:details][:announcements] || []
    end

    def update_sub_sections
      coronavirus_page.sub_sections.destroy_all
      coronavirus_page.sub_sections = sub_sections
    end

    def sub_sections
      sections = SectionsPresenter.new(sections_from_payload).output

      new_sub_sections = sections.each_with_index.map do |attributes, index|
        Coronavirus::SubSection.new(
          title: attributes[:title],
          content: attributes[:content],
          position: index,
        )
      end

      new_sub_sections
    end

    def sections_from_payload
      payload_from_publishing_api[:details][:sections] || []
    end

    def update_timeline_entries
      coronavirus_page.timeline_entries.delete_all
      coronavirus_page.timeline_entries = timeline_entries
    end

    def timeline_entries
      timeline_entries_from_payload.reverse.map do |attributes|
        Coronavirus::TimelineEntry.new(
          heading: attributes[:heading],
          content: attributes[:paragraph],
        )
      end
    end

    def timeline_entries_from_payload
      payload_from_publishing_api.dig(:details, :timeline, :list) || []
    end

    def payload_from_publishing_api
      @payload_from_publishing_api ||=
        begin
          content = GdsApi.publishing_api.get_live_content(coronavirus_page.content_id).to_h
          content.with_indifferent_access
        rescue GdsApi::PublishingApi::NoLiveVersion, GdsApi::HTTPErrorResponse
          {}
        end
    end
  end
end
