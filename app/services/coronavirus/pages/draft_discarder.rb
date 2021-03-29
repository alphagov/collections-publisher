module Coronavirus::Pages
  class DraftDiscarder
    attr_reader :page

    def initialize(page)
      @page = page
    end

    def call
      return if payload_from_publishing_api.blank?

      Coronavirus::Page.transaction do
        page.update!(state: "published")
        update_announcements
        update_sub_sections
        update_timeline_entries
      end
    end

  private

    def update_announcements
      page.announcements.delete_all
      page.announcements = announcements
    end

    def announcements
      announcements_from_payload.map.with_index do |announcement, index|
        Coronavirus::Announcement.new(
          title: announcement[:text],
          url: announcement[:href],
          published_on: Date.parse(announcement[:published_text]),
          position: index + 1,
        )
      end
    end

    def announcements_from_payload
      payload_from_publishing_api[:details][:announcements] || []
    end

    def update_sub_sections
      page.sub_sections.destroy_all
      page.sub_sections = sub_sections
    end

    def sub_sections
      sections = SectionsPresenter.new(sections_from_payload).output

      new_sub_sections = sections.each_with_index.map do |attributes, index|
        Coronavirus::SubSection.new(
          title: attributes[:title],
          content: attributes[:content],
          position: index,
          action_link_url: attributes[:action_link_url],
          action_link_content: attributes[:action_link_content],
          action_link_summary: attributes[:action_link_summary],
        )
      end

      new_sub_sections
    end

    def sections_from_payload
      payload_from_publishing_api[:details][:sections] || []
    end

    def update_timeline_entries
      page.timeline_entries.delete_all
      page.timeline_entries = timeline_entries
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
          content = GdsApi.publishing_api.get_live_content(page.content_id).to_h
          content.with_indifferent_access
        rescue GdsApi::PublishingApi::NoLiveVersion, GdsApi::HTTPErrorResponse
          {}
        end
    end
  end
end
