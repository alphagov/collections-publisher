# require 'gds_api/test_helpers/publishing_api'

# RSpec.configure do |config|
#   config.include GdsApi::TestHelpers::PublishingApi, :type => :feature
# #   config.before :each, :type => :feature do
# #     stub_default_publishing_api_v2_put
# #     stub_default_publishing_api_v2_put_draft
# #   end
# end
module PublishingApiHelpers


  PUBLISHING_API_ENDPOINT = Plek.current.find('publishing-api')


  def stub_put_content_to_publishing_api
    stub_request(:put, %r{\A#{PUBLISHING_API_ENDPOINT}/v2/content})
  end

  def stub_put_links_to_publishing_api
    stub_request(:put, %r{\A#{PUBLISHING_API_ENDPOINT}/v2/links})
  end

  def stub_put_content_and_links_to_publishing_api
    stub_put_content_to_publishing_api
    stub_put_links_to_publishing_api
  end

  def stub_publish_to_publishing_api
    stub_request(:post, %r{\A#{PUBLISHING_API_ENDPOINT}/v2/content\/.*\/publish})
  end

  def stub_put_content_links_and_publish_to_publishing_api
    stub_put_content_to_publishing_api
    stub_put_links_to_publishing_api
    stub_publish_to_publishing_api
  end

  def request_json_matching(required_attributes)
    ->(request) do
      data = JSON.parse(request.body)
      required_attributes.to_a.all? { |key, value| data[key.to_s] == value }
    end
  end


  def assert_publishing_api_put_item(content_id, attributes_or_matcher = {}, times = 1)
    url = PUBLISHING_API_ENDPOINT + "/v2/content/" + content_id
    assert_publishing_api_put(url, attributes_or_matcher, times)
  end

  def assert_publishing_api_publish(content_id)
    url = "#{PUBLISHING_API_ENDPOINT}/v2/content/#{content_id}/publish"
    assert_requested(:post, url, times: 1)
  end

  def assert_publishing_api_not_published(content_id)
    url = "#{PUBLISHING_API_ENDPOINT}/v2/content/#{content_id}/publish"
    assert_not_requested(:post, url)
  end

  def assert_publishing_api_put_links(content_id)
    assert_requested(:put, "#{PUBLISHING_API_ENDPOINT}/v2/links/#{content_id}")
  end


  def assert_publishing_api_put(url, attributes_or_matcher = {}, times = 1)
    if attributes_or_matcher.is_a?(Hash)
      matcher = attributes_or_matcher.empty? ? nil : request_json_matching(attributes_or_matcher)
    else
      matcher = attributes_or_matcher
    end

    if matcher
      assert_requested(:put, url, times: times, &matcher)
    else
      assert_requested(:put, url, times: times)
    end
  end

  def extract_content_id_from(current_path)
    /.*\/(?<content_id>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})(\/.*)?$/ =~ current_path
    content_id || "no-content-id-found-in-#{current_path}"
  end

end
