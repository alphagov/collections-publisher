module Coronavirus::Pages
  class DraftUpdater
    class DraftUpdaterError < RuntimeError; end

    attr_reader :page

    def initialize(page)
      @page = page
    end

    delegate :content_id, :base_path, to: :page

    def content_builder
      @content_builder ||= ContentBuilder.new(page)
    end

    def payload
      Coronavirus::PagePresenter.new(content_builder.data, base_path).payload
    end

    def send
      @send ||= Services.publishing_api.put_content(content_id, payload)
      page.update!(state: "draft")
    rescue GdsApi::HTTPErrorResponse
      raise DraftUpdaterError, "Failed to update the draft content item. Try saving again."
    end

    def discard
      Services.publishing_api.discard_draft(content_id)
    rescue GdsApi::HTTPUnprocessableEntity
      raise DraftUpdaterError, "You do not have a draft to discard"
    rescue GdsApi::HTTPErrorResponse
      raise DraftUpdaterError, "There has been an error discarding your changes. Try again."
    end
  end
end
