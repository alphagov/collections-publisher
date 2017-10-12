class EmailAlertSignupPresenter
  def initialize(subtopic)
    self.subtopic = subtopic
  end

  def content_payload
    {
      base_path: base_path,
      document_type: "email_alert_signup",
      schema_name: "email_alert_signup",
      title: subtopic.title,
      description: "#{subtopic.title} Email Alert Signup",
      public_updated_at: public_updated_at,
      locale: "en",
      publishing_app: "collections-publisher",
      rendering_app: "email-alert-frontend",
      routes: routes,
      details: details,
      update_type: update_type,
    }
  end

  def content_id
    Services.publishing_api.lookup_content_id(base_path: base_path) || SecureRandom.uuid
  end

  def update_type
    "republish"
  end

private

  attr_accessor :subtopic

  def subtopic_base_path
    "/topic/#{subtopic.parent.slug}/#{subtopic.slug}"
  end

  def base_path
    "#{subtopic_base_path}/email-signup"
  end

  def public_updated_at
    Time.zone.now.iso8601
  end

  def routes
    [{ path: base_path, type: "exact" }]
  end

  def details
    {
      subscriber_list: {
        document_type: "topic",
        links: subscriber_list_links,
      },
      summary: summary,
      breadcrumbs: breadcrumbs,
      govdelivery_title: subtopic.title,
    }
  end

  def subscriber_list_links
    { topics: [subtopic.content_id] }
  end

  def summary
    "You’ll get an email each time content is published or updated in this topic."
  end

  def breadcrumbs
    [
      {
        title: subtopic.title,
        link: subtopic_base_path,
      }
    ]
  end
end
