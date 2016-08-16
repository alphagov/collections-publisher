require 'services'
require 'gds_api/test_helpers/publishing_api_v2'

module PublishingApiHelpers
  include GdsApi::TestHelpers::PublishingApiV2

  def assert_publishing_api_not_published(content_id)
    url = Plek.current.find('publishing-api') + "/v2/content/#{content_id}/publish"
    assert_not_requested(:post, url)
  end

  def extract_content_id_from(current_path)
    /.*\/(?<content_id>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(\/.*)?$/ =~ current_path
    content_id || "no-content-id-found-in-#{current_path}"
  end

  # TODO: Move this to gds-api-adapters
  def publishing_api_has_linked_items(content_id, items:)
    url = PUBLISHING_API_V2_ENDPOINT + "/linked/" + content_id
    stub_request(:get, %r[#{url}]).to_return(status: 200, body: items.to_json)
  end

  # TODO: Move this to gds-api-adapters
  def publishing_api_has_no_linked_items
    url = PUBLISHING_API_V2_ENDPOINT + "/linked/"
    stub_request(:get, %r[#{url}]).to_return(status: 200, body: [].to_json)
  end
end

RSpec.configure do |config|
  config.include PublishingApiHelpers
end
