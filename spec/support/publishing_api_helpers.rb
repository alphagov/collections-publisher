require 'gds_api/test_helpers/publishing_api'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::PublishingApi, :type => :feature
  config.before :each, :type => :feature do
    stub_default_publishing_api_put
    stub_default_publishing_api_put_draft
  end
end
