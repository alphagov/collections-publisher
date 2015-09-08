module CollectionsPublisher
  def self.services(name, service = nil)
    @services ||= {}

    if service
      @services[name] = service
      return true
    else
      if @services[name]
        return @services[name]
      else
        raise ServiceNotRegisteredException.new(name)
      end
    end
  end

  class ServiceNotRegisteredException < Exception; end
end

require 'gds_api/publishing_api'

module Services
  def self.publishing_api
    @publishing_api ||= GdsApi::PublishingApi.new(Plek.new.find('publishing-api'))
  end

  def self.panopticon
    @panopticon ||= CollectionsPublisher.services(:panopticon)
  end
end

class GdsApi::HTTPConflict < GdsApi::HTTPClientError
end

class GdsApi::Panopticon < GdsApi::Base
  def delete_tag!(tag_type, tag_id)
    delete_json!(tag_url(tag_type, tag_id))
  rescue GdsApi::HTTPClientError => e
    if e.code == 409
      raise GdsApi::HTTPConflict.new(e.code, e.message, e.error_details)
    else
      raise e
    end
  end
end

require 'gds_api/panopticon'
CollectionsPublisher.services(
  :panopticon,
  GdsApi::Panopticon.new(Plek.new.find('panopticon'),
                         bearer_token: ENV['PANOPTICON_BEARER_TOKEN'] || 'example'))

require 'gds_api/rummager'
CollectionsPublisher.services(:rummager, GdsApi::Rummager.new(Plek.new.find('rummager')))
