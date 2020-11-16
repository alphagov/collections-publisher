module CoronavirusPages
  class DraftDiscarder
    attr_reader :coronavirus_page, :payload_from_publishing_api

    def initialize(coronavirus_page, payload_from_publishing_api)
      @coronavirus_page = coronavirus_page
      @payload_from_publishing_api = payload_from_publishing_api.with_indifferent_access
    end

    def call
      update_announcements
    end

  private

    def update_announcements
      coronavirus_page.announcements.delete_all
      coronavirus_page.announcements = announcements
    end

    def announcements
      announcements_from_payload.map.with_index do |announcement, index|
        Announcement.new(
          text: announcement[:text],
          href: announcement[:href],
          published_at: Date.parse(announcement[:published_text]),
          position: index + 1,
        )
      end
    end

    def announcements_from_payload
      payload_from_publishing_api[:details][:announcements] || []
    end
  end
end
