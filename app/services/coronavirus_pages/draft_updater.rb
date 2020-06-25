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
        CoronavirusPagePresenter.new(content_builder.data, base_path)
      else
        raise DraftUpdaterError, content_builder.errors.to_sentence
      end
    end

    def send
      @send ||= Services.publishing_api.put_content(content_id, payload)
    end

    def errors
      return if send
    rescue GdsApi::HTTPGatewayTimeout
      # TODO: Send to sentry
      "Updating the draft timed out - please try again"
    rescue DraftUpdaterError => e
      e.message
    end
  end
end
