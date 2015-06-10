require 'gds_api/test_helpers/content_api'

module ContentApiHelpers
  include GdsApi::TestHelpers::ContentApi

  def contentapi_url_for_slug(slug)
    "#{Plek.new.find('contentapi')}/#{slug}.json"
  end

  def stub_content_api(result)
    stub_request(:get, %r[.contentapi]).to_return(body: JSON.dump(result))
  end
end

RSpec.configure do |config|
  config.include ContentApiHelpers, :type => :feature
end
