module EmailAlertApi
  class SubscriberListFetcher
    def initialize(params)
      @params = params
    end

    attr_reader :params

    def find_slug
      subscriber_list = Services.email_alert_api.find_subscriber_list(params)
      subscriber_list.dig("subscriber_list", "slug")
    end

    def find_or_create_slug
      subscriber_list = Services.email_alert_api.find_or_create_subscriber_list(params)
      subscriber_list.dig("subscriber_list", "slug")
    end
  end
end
