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

# Only used by rake task `populate_published_groups`
require 'gds_api/content_store'
CollectionsPublisher.services(:content_store, GdsApi::ContentStore.new(Plek.new.find('content-store')))

require 'gds_api/content_api'
CollectionsPublisher.services(:content_api, GdsApi::ContentApi.new(Plek.new.find('content_api')))

require 'gds_api/publishing_api'
CollectionsPublisher.services(:publishing_api, GdsApi::PublishingApi.new(Plek.new.find('publishing-api')))

require 'gds_api/panopticon'
CollectionsPublisher.services(
  :panopticon,
  GdsApi::Panopticon.new(Plek.new.find('panopticon'),
                         bearer_token: ENV['PANOPTICON_BEARER_TOKEN'] || 'example'))

require 'gds_api/rummager'
CollectionsPublisher.services(:rummager, GdsApi::Rummager.new(Plek.new.find('rummager')))
