class EmailAlertsUpdater
  def self.call(...)
    new(...).unsubscribe
  end

  attr_reader :item, :body

  def initialize(item:, body: nil)
    @item = item
    @body = body
  end

  def unsubscribe
    args = { slug: subscriber_list_slug }

    if body
      args.merge!({
        body:,
        sender_message_id: SecureRandom.uuid,
      })
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
