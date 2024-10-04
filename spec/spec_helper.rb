ENV["GOVUK_APP_DOMAIN"] ||= "test.gov.uk"
ENV["GOVUK_ASSET_ROOT"] ||= "http://static.test.gov.uk"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.default_formatter = config.files_to_run.one? ? "doc" : "progress"

  config.order = :random

  Kernel.srand config.seed

  config.before :each, type: :controller do
    # Set a referer header so `redirect_to :back` works in tests.
    request.env["HTTP_REFERER"] = ""
  end

  config.before(:each) do
    Sidekiq::Job.clear_all
    Sidekiq::Testing.inline!
  end
end
