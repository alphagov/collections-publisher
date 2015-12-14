require 'govuk-content-schema-test-helpers'

GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = 'publisher_v2'
  config.project_root = Rails.root
end

require 'govuk-content-schema-test-helpers/rspec_matchers'

RSpec.configuration.include GovukContentSchemaTestHelpers::RSpecMatchers
