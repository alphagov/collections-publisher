class EmailAlertsUpdater
  def self.call(...)
    new(...).unsubscribe
  end

  attr_reader :item, :body, :govuk_request_id

  def initialize(item:, body: nil, govuk_request_id: nil)
    @item = item
    @body = body
    @govuk_request_id = govuk_request_id
  end

  def unsubscribe
    args = { slug: subscriber_list_slug }

    if body
      args.merge!({
        body:,
        sender_message_id: SecureRandom.uuid,
      })

      # GOVUK-Request-Id HTTP header is set by Nginx and handled by gds-api-adapters.
      # For out-of-band processes (asynchronous workers)
      # it needs to be set explicitly to send emails.
      args.merge!({ govuk_request_id: }) if govuk_request_id
    end

    Services.email_alert_api.bulk_unsubscribe(**args)
  end

private

  def subscriber_list_slug
    subscriber_list = Services.email_alert_api.find_subscriber_list(
      item.subscriber_list_search_attributes,
    )
    subscriber_list.dig("subscriber_list", "slug")
  end
end
