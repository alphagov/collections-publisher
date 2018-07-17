require 'gds_api/publishing_api_v2'
require 'gds_api/content_store'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(
      Plek.new.find('content-store'),
      disable_cache: true
    )
  end

  def self.draft_origin
    @draft_origin ||= Plek.new.external_url_for('draft-origin')
  end
end
