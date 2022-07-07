require "gds_api/publishing_api"
require "gds_api/content_store"
require "gds_api/link_checker_api"
require "gds_api/email_alert_api"

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(
      Plek.new.find("content-store"),
      disable_cache: true,
    )
  end

  def self.link_checker_api
    @link_checker_api ||= GdsApi::LinkCheckerApi.new(
      Plek.new.find("link-checker-api"),
      bearer_token: ENV["LINK_CHECKER_API_BEARER_TOKEN"],
    )
  end

  def self.email_alert_api
    @email_alert_api || GdsApi::EmailAlertApi.new(
      Plek.new.find("email-alert-api"),
      bearer_token: ENV["EMAIL_ALERT_API_BEARER_TOKEN"],
    )
  end
end
