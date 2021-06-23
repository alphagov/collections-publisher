require "services"
require "gds_api/test_helpers/publishing_api"

module PublishingApiHelpers
  include GdsApi::TestHelpers::PublishingApi

  def assert_publishing_api_not_published(content_id)
    url = Plek.current.find("publishing-api") + "/v2/content/#{content_id}/publish"
    assert_not_requested(:post, url)
  end

  def extract_content_id_from(current_path)
    /.*\/(?<content_id>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(?:\/.*)?$/ =~ current_path
    content_id || "no-content-id-found-in-#{current_path}"
  end

  # TODO: Move this to gds-api-adapters
  def publishing_api_has_linked_items(content_id, items:)
    url = "#{PUBLISHING_API_V2_ENDPOINT}/linked/#{content_id}"
    stub_request(:get, %r{#{url}}).to_return(status: 200, body: items.to_json)
  end

  # TODO: Move this to gds-api-adapters
  def publishing_api_has_no_linked_items
    url = "#{PUBLISHING_API_V2_ENDPOINT}/linked/"
    stub_request(:get, %r{#{url}}).to_return(status: 200, body: [].to_json)
  end

  def publishing_api_receives_request_to_lookup_content_id(base_path:)
    allow(Services.publishing_api).to(
      receive(:lookup_content_id).with(
        base_path: base_path,
        with_drafts: true,
      ),
    )
  end

  def publishing_api_receives_request_to_lookup_content_ids(base_paths:, return_data: nil)
    expectation = expect(Services.publishing_api).to receive(:lookup_content_ids).with(
      base_paths: base_paths,
      with_drafts: true,
    )

    if return_data
      expectation.and_return(
        return_data,
      )
    end
  end

  def publishing_api_receives_get_content_id_request(content_items:)
    content_items.each do |content_item|
      expect(Services.publishing_api).to(
        receive(:get_content).with(content_item[:content_id]),
      ).and_return(content_item)
    end
  end
end

RSpec.configure do |config|
  config.include PublishingApiHelpers
end
