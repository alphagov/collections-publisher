module EmailAlerts
  class EmailAlertsUpdater
    def self.call(...)
      new(...).bulk_update
    end

    attr_reader :specialist_topic, :successor, :destination_picker

    def initialize(specialist_topic:, successor:, destination_picker: MigrationDestinationPicker)
      @specialist_topic = specialist_topic
      @successor = successor
      @destination_picker = destination_picker.new(specialist_topic, successor)
    end

    def bulk_update
      if to_slug
        BulkMigrator.new(from_slug, to_slug).send_to_email_alert_api
      else
        BulkUnsubscriber.new(from_slug, successor_base_path).send_to_email_alert_api
      end
    end

    delegate :to_slug, to: :destination_picker

    delegate :from_slug, to: :destination_picker

    delegate :base_path, to: :successor, prefix: true
  end
end
