class EmailAlertsUnsubscriber
  def self.call(*args)
    new(*args).unsubscribe
  end

  attr_reader :slug, :body, :govuk_request_id

  def initialize(slug:, body: nil)
    @slug = slug
    @body = body
    @govuk_request_id = govuk_request_id
  end

  def unsubscribe
    args = { slug: slug }

    if body
      args.merge!({
        body: body,
        sender_message_id: SecureRandom.uuid,
      })
    end

    Services.email_alert_api.bulk_unsubscribe(args)
  end
end
