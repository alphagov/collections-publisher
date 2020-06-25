class PublisherNotifications < ApplicationMailer
  include ApplicationHelper

  PUBLISH_WITHOUT_2I_EMAIL = ENV.fetch("PUBLISH_WITHOUT_2I_EMAIL", "test-email-address@gmail.com").freeze

  def publish_without_2i(step_by_step_page, current_user)
    @current_user = current_user
    @step_by_step_page = step_by_step_page
    @live_url = published_url(step_by_step_page.slug)

    view_mail(template_id,
              to: PUBLISH_WITHOUT_2I_EMAIL,
              subject: "[PUBLISHER] Step by step published without 2i review for '#{step_by_step_page.title}'")
  end
end
