class EmailAlertsUnsubscriber
  def self.call(*args)
    new(*args).unsubscribe
  end

  attr_reader :slug, :body, :govuk_request_id

  def initialize(slug:, body: nil, govuk_request_id: nil)
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

      # GOVUK-Request-Id HTTP header is set by Nginx and handled by gds-api-adapters.
      # For out-of-band processes (asynchronous workers)
      # it needs to be set explicitly to send emails.
      args.merge!({ govuk_request_id: govuk_request_id }) if govuk_request_id
    end

    Services.email_alert_api.bulk_unsubscribe(args)
  end
end
