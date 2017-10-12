class EmailAlertSignupPublisher
  def republish_email_alert_signups
    Topic.all.each do |topic|
      if topic.subtopic?
        presenter = EmailAlertSignupPresenter.new(topic)
        content_id = presenter.content_id
        Services.publishing_api.put_content(content_id, presenter.content_payload)
        Services.publishing_api.publish(content_id, presenter.update_type)
      end
    end
  end
end
