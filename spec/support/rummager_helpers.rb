require 'gds_api/test_helpers/rummager'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::Rummager, type: :feature
end
