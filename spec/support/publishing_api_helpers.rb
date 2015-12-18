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
end
