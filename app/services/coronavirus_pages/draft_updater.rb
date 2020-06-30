module CoronavirusPages
  class DraftUpdater
    DraftUpdaterError = Class.new(StandardError)

    attr_reader :coronavirus_page

    def initialize(coronavirus_page)
      @coronavirus_page = coronavirus_page
    end

    delegate :content_id, :base_path, to: :coronavirus_page

    def content_builder
      @content_builder ||= CoronavirusPages::ContentBuilder.new(coronavirus_page)
    end

    def payload
      if content_builder.success?
        CoronavirusPagePresenter.new(content_builder.data, base_path).payload
      else
        raise DraftUpdaterError, content_builder.errors.to_sentence
      end
    end

    def send
      @send ||= Services.publishing_api.put_content(content_id, payload)
    rescue GdsApi::HTTPServerError => e
      error_handler(e, "Failed to update the draft content item - please try saving again")
    rescue GdsApi::HTTPUnprocessableEntity, DraftUpdaterError => e
      error_handler(e)
    end

    def errors
      @errors ||= []
    end

    def error_handler(error, message = nil)
      GovukError.notify(error, extra: { content_id: content_id, coronavirus_page_slug: coronavirus_page.slug })
      errors << (message || error.message)
      false
    end
  end
end
