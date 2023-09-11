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
      if subscribers_can_be_migrated_to_mapped_taxonomy_topic_list?
        bulk_migrate(subscriber_list_slug_for_taxonomy_topic_email_override)
      elsif subscribers_can_be_migrated_to_successor_list?
        bulk_migrate(subscriber_list_slug_for_document_collection)
      else
        bulk_unsubscribe
      end
    end

  private

    def bulk_migrate(destination_list_slug)
      Services.email_alert_api
      .bulk_migrate(
        from_slug: subscriber_list_slug_for_specialist_topic,
        to_slug: destination_list_slug,
      )
    end

    def bulk_unsubscribe
      args = {
        slug: subscriber_list_slug_for_specialist_topic,
        body: unsubscribe_email_body,
        sender_message_id: SecureRandom.uuid,
      }

      Services.email_alert_api.bulk_unsubscribe(**args)
    end

    def subscribers_can_be_migrated_to_successor_list?
      successor.mapped_specialist_topic_content_id == item.content_id
    end

    def subscribers_can_be_migrated_to_mapped_taxonomy_topic_list?
      successor.taxonomy_topic_email_override.present?
    end

    def subscriber_list_slug_for_specialist_topic
      EmailAlertApi::SubscriberListFetcher.new(
        specialist_topic_subscriber_list_params(item),
      ).find_slug
    end

    def subscriber_list_slug_for_document_collection
      EmailAlertApi::SubscriberListFetcher.new(
        document_collection_subscriber_list_params(successor),
      ).find_or_create_slug
    end

    def taxonomy_topic_content_item
      links_data = successor.taxonomy_topic_email_override
      ContentItem.find!(links_data["base_path"])
    end

    def subscriber_list_slug_for_taxonomy_topic_email_override
      EmailAlertApi::SubscriberListFetcher.new(
        taxonomy_topic_subscriber_list_params(taxonomy_topic_content_item),
      ).find_or_create_slug
    end

    def unsubscribe_email_body
      <<~BODY
        This topic has been archived. You will not get any more emails about it.

        You can find more information about this topic at [#{Plek.website_root + successor.base_path}](#{Plek.website_root + successor.base_path}).
      BODY
    end
  end
end
