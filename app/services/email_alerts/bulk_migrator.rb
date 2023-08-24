module EmailAlerts
  class BulkMigrator
    def initialize(from_slug, to_slug)
      @from_slug = from_slug
      @to_slug = to_slug
    end

    attr_reader :from_slug, :to_slug

    def send_to_email_alert_api
      Services.email_alert_api.bulk_migrate(from_slug:, to_slug:)
    end
  end
end
