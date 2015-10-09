require 'gds_api/publishing_api'
require 'gds_api/panopticon'
require 'gds_api/rummager'
require 'gds_api/content_store'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.new.find('content-store'))
  end

  def self.panopticon
    @panopticon ||= GdsApi::Panopticon.new(
      Plek.new.find('panopticon'),
      bearer_token: ENV['PANOPTICON_BEARER_TOKEN'] || 'example'
    )
  end

  def self.rummager
    @rummager ||= GdsApi::Rummager.new(Plek.new.find('rummager'))
  end
end

class GdsApi::Panopticon < GdsApi::Base
  def delete_tag!(tag_type, tag_id)
    delete_json!(tag_url(tag_type, tag_id))
  end
end
