require 'gds_api/test_helpers/publishing_api'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::PublishingApi, :type => :feature
end
