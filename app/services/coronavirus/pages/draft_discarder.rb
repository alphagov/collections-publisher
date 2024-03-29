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
        update_sub_sections
      end
    end

  private

    def update_sub_sections
      page.sub_sections.destroy_all
      page.sub_sections = sub_sections
    end

    def sub_sections
      sections = SectionsPresenter.new(sections_from_payload).output

      sections.each_with_index.map do |attributes, index|
        Coronavirus::SubSection.new(
          title: attributes[:title],
          content: attributes[:content],
          position: index,
          action_link_url: attributes[:action_link_url],
          action_link_content: attributes[:action_link_content],
          action_link_summary: attributes[:action_link_summary],
        )
      end
    end

    def sections_from_payload
      payload_from_publishing_api[:details][:sections] || []
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
