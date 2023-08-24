module EmailAlerts
  class MigrationDestinationPicker
    include EmailAlertsApiParamsHelper

    def initialize(specialist_topic, successor)
      @specialist_topic = specialist_topic
      @successor = successor
    end

    attr_reader :specialist_topic, :successor

    def to_slug
      taxonomy_topic_override_slug || document_collection_slug
    end

    def document_collection_slug
      return unless successor.mapped_specialist_topic_content_id == specialist_topic.content_id

      params = document_collection_subscriber_list_params(successor)
      subscriber_list_slug(params)
    end

    def taxonomy_topic_override_slug
      return if successor.taxonomy_topic_email_override.blank?

      params = taxonomy_topic_subscriber_list_params(successor)
      subscriber_list_slug(params)
    end

    def subscriber_list_slug(params)
      Services.email_alert_api.find_or_create_subscriber_list(params).dig("subscriber_list", "slug")
    end

    def from_slug
      params = specialist_topic_subscriber_list_params(specialist_topic)
      subscriber_list = Services.email_alert_api.find_subscriber_list(params)
      subscriber_list.dig("subscriber_list", "slug")
    end
  end
end
