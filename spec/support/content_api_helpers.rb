require 'gds_api/test_helpers/content_api'

module ContentApiHelpers
  include GdsApi::TestHelpers::ContentApi

  def contentapi_url_for_slug(slug)
    "#{Plek.new.find('contentapi')}/#{slug}.json"
  end
end

RSpec.configure do |config|
  config.include ContentApiHelpers, :type => :feature
end
