module EmailAlerts
  class BulkUnsubscriber
    def initialize(from_slug, successor_base_path)
      @from_slug = from_slug
      @successor_base_path = successor_base_path
    end

    attr_reader :from_slug, :successor_base_path

    def send_to_email_alert_api
      args = {
        slug: from_slug,
        body: unsubscribe_email_body,
        sender_message_id: SecureRandom.uuid,
      }

      Services.email_alert_api.bulk_unsubscribe(**args)
    end

    def unsubscribe_email_body
      <<~BODY
        This topic has been archived. You will not get any more emails about it.

        You can find more information about this topic at [#{Plek.website_root + successor_base_path}](#{Plek.website_root + successor_base_path}).
      BODY
    end
  end
end
