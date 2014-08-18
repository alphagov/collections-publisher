module CollectionsPublisher
  def self.services(name, service = nil)
    @services ||= {}
    @services[name] = service if service
    @services[name]
  end
end

require 'gds_api/content_api'
CollectionsPublisher.services(:content_api, GdsApi::ContentApi.new(Plek.new.find('content_api')))
