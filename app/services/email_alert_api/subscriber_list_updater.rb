module EmailAlertApi
  class SubscriberListUpdater
    include ParamsFormatter

    def self.call(...)
      new(...).handle
    end

    attr_reader :item, :content_item

    def initialize(item:, content_item:)
      @item = item
      @content_item = content_item
    end

    def handle
      if subscribers_can_be_migrated_to_mapped_taxonomy_topic_list?
        bulk_migrate(subscriber_list_slug_for_taxonomy_topic_email_override)
      elsif subscribers_can_be_migrated_to_document_collection_list?
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

    def subscribers_can_be_migrated_to_document_collection_list?
      content_item.mapped_specialist_topic_content_id == item.content_id
    end

    def subscribers_can_be_migrated_to_mapped_taxonomy_topic_list?
      content_item.taxonomy_topic_email_override.present?
    end

    def subscriber_list_slug_for_specialist_topic
      EmailAlertApi::SubscriberListFetcher.new(
        specialist_topic_subscriber_list_params(item),
      ).find_slug
    end

    def subscriber_list_slug_for_document_collection
      EmailAlertApi::SubscriberListFetcher.new(
        document_collection_subscriber_list_params(content_item),
      ).find_or_create_slug
    end

    def taxonomy_topic_content_item
      links_data = content_item.taxonomy_topic_email_override
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

        You can find more information about this topic at [#{Plek.website_root + content_item.base_path}](#{Plek.website_root + content_item.base_path}).
      BODY
    end
  end
end
