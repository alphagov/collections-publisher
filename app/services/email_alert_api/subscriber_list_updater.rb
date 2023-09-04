module EmailAlertApi
  class SubscriberListUpdater
    include ParamsFormatter

    def self.call(...)
      new(...).handle
    end

    attr_reader :item, :successor

    def initialize(item:, successor:)
      @item = item
      @successor = successor
    end

    def handle
      if subscribers_can_be_migrated_to_successor_list?
        bulk_migrate
      else
        bulk_unsubscribe
      end
    end

    def bulk_migrate
      from_slug = subscriber_list_slug_for_specialist_topic
      to_slug = subscriber_list_slug_for_document_collection
      Services.email_alert_api.bulk_migrate(from_slug:, to_slug:)
    end

    def bulk_unsubscribe
      args = {
        slug: subscriber_list_slug_for_specialist_topic,
        body: unsubscribe_email_body,
        sender_message_id: SecureRandom.uuid,
      }

      Services.email_alert_api.bulk_unsubscribe(**args)
    end

  private

    def subscribers_can_be_migrated_to_successor_list?
      successor.mapped_specialist_topic_content_id == item.content_id
    end

    def subscriber_list_slug_for_specialist_topic
      params = specialist_topic_subscriber_list_params(item)
      subscriber_list = Services.email_alert_api.find_subscriber_list(params)
      subscriber_list.dig("subscriber_list", "slug")
    end

    def subscriber_list_slug_for_document_collection
      params = document_collection_subscriber_list_params(successor)
      Services.email_alert_api.find_or_create_subscriber_list(params).dig("subscriber_list", "slug")
    end

    def unsubscribe_email_body
      <<~BODY
        This topic has been archived. You will not get any more emails about it.

        You can find more information about this topic at [#{Plek.website_root + successor.base_path}](#{Plek.website_root + successor.base_path}).
      BODY
    end
  end
end
