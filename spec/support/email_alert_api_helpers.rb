require "services"
require "gds_api/test_helpers/email_alert_api"

module EmailAlertApiHelpers
  include GdsApi::TestHelpers::EmailAlertApi

  # TODO: Move this to gds-api-adapters
  def email_alert_api_has_subscriber_list_for_topic(content_id:, list: {})
    url = "#{EMAIL_ALERT_API_ENDPOINT}/subscriber-lists?links%5Btopics%5D%5B0%5D=#{content_id}"
    stub_request(:get, url).to_return(status: 200, body: { "subscriber_list" => list }.to_json)
  end
end

RSpec.configure do |config|
  config.include EmailAlertApiHelpers
end
