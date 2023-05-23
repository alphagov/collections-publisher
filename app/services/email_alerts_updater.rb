class EmailAlertsUpdater
  def self.call(...)
    new(...).unsubscribe
  end

  attr_reader :item, :successor

  def initialize(item:, successor:)
    @item = item
    @successor = successor
  end

  def unsubscribe
    args = {
      slug: subscriber_list_slug,
      body: unsubscribe_email_body,
      sender_message_id: SecureRandom.uuid,
    }

    Services.email_alert_api.bulk_unsubscribe(**args)
  end

private

  def subscriber_list_slug
    subscriber_list = Services.email_alert_api.find_subscriber_list(
      item.subscriber_list_search_attributes,
    )
    subscriber_list.dig("subscriber_list", "slug")
  end

  def unsubscribe_email_body
    <<~BODY
      This topic has been archived. You will not get any more emails about it.

      You can find more information about this topic at [#{Plek.website_root + successor.base_path}](#{Plek.website_root + successor.base_path}).
    BODY
  end
end
