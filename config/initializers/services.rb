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
CollectionsPublisher.services(:publishing_api, GdsApi::PublishingApi.new(Plek.new.find('publishing-api')))

require 'gds_api/panopticon'
CollectionsPublisher.services(
  :panopticon,
  GdsApi::Panopticon.new(Plek.new.find('panopticon'),
                         bearer_token: ENV['PANOPTICON_BEARER_TOKEN'] || 'example'))

require 'gds_api/rummager'
CollectionsPublisher.services(:rummager, GdsApi::Rummager.new(Plek.new.find('rummager')))
