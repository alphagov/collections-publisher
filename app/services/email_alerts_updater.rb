class EmailAlertsUpdater
  include EmailAlertsApiParamsHelper

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
      bulk_migrate_to_mapped_taxonomy_topic_list
    elsif subscribers_can_be_migrated_to_successor_list?
      bulk_migrate_to_successor_list
    else
      bulk_unsubscribe
    end
  end

  def bulk_migrate_to_successor_list
    from_slug = topic_subscriber_list_slug
    to_slug = existing_subscriber_list_slug_for_document_collection
    Services.email_alert_api.bulk_migrate(from_slug:, to_slug:)
  end

  def bulk_migrate_to_mapped_taxonomy_topic_list
    from_slug = topic_subscriber_list_slug
    to_slug = existing_subscriber_list_slug_for_taxonomy_topic_email_override
    Services.email_alert_api.bulk_migrate(from_slug:, to_slug:)
  end

  def bulk_unsubscribe
    args = {
      slug: topic_subscriber_list_slug,
      body: unsubscribe_email_body,
      sender_message_id: SecureRandom.uuid,
    }

    Services.email_alert_api.bulk_unsubscribe(**args)
  end

private

  def subscribers_can_be_migrated_to_successor_list?
    successor.mapped_specialist_topic_content_id == item.content_id
  end

  def subscribers_can_be_migrated_to_mapped_taxonomy_topic_list?
    taxonomy_topic_email_override.present?
  end

  def taxonomy_topic_email_override
    successor.taxonomy_topic_email_override
  end

  def existing_subscriber_list_slug_for_taxonomy_topic_email_override
    params = taxonomy_topic_subscriber_list_params(item)
    subscriber_list = Services.email_alert_api.find_subscriber_list(params)
    subscriber_list.dig("subscriber_list", "slug")
  end

  def topic_subscriber_list_slug
    params = specialist_topic_subscriber_list_params(item)
    subscriber_list = Services.email_alert_api.find_subscriber_list(params)
    subscriber_list.dig("subscriber_list", "slug")
  end

  def existing_subscriber_list_slug_for_document_collection
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
