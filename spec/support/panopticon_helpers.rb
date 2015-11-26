require 'gds_api/test_helpers/panopticon'

module PanopticonHelpers
  include GdsApi::TestHelpers::Panopticon

  # Override stub_panopticon_tag_creation & stub_panopticon_tag_update to take
  # a hash for `body` instead of a JSON-string. This allows us to use the
  # `kind_of()` matcher in our tests.
  def stub_panopticon_tag_creation(attributes)
    url = "#{PANOPTICON_ENDPOINT}/tags.json"
    stub_request(:post, url)
      .with(body: attributes)
      .to_return(status: 201, body: attributes.to_json)
  end

  def stub_panopticon_tag_update(tag_type, tag_id, attributes)
    url = "#{PANOPTICON_ENDPOINT}/tags/#{tag_type}/#{tag_id}.json"
    stub_request(:put, url)
      .with(body: attributes)
      .to_return(status: 200)
  end

  def stub_all_panopticon_tag_calls
    base_url = "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/tags"
    stub_request(:post, "#{base_url}.json")
      .to_return(:status => 201)
    stub_request(:put, %r{\A#{base_url}/})
      .to_return(:status => 200)
    stub_request(:post, %r{\A#{base_url}/})
      .to_return(:status => 200)
  end

  def assert_tag_created_in_panopticon(payload)
    payload[:content_id] ||= kind_of(String)
    payload[:parent_id] ||= nil
    payload = Hash[payload.sort]
    request = stub_panopticon_tag_creation(payload)
    expect(request).to have_been_requested
  end

  def assert_tag_updated_in_panopticon(payload)
    payload[:content_id] ||= kind_of(String)
    payload[:parent_id] = nil
    payload = Hash[payload.sort]
    request = stub_panopticon_tag_update(payload[:tag_type], payload[:tag_id], payload)
    expect(request).to have_been_requested
  end

  def assert_tag_published_in_panopticon(tag_id:, tag_type:)
    request = stub_panopticon_tag_publish(tag_type, tag_id)
    expect(request).to have_been_requested
  end
end

RSpec.configure do |config|
  config.include PanopticonHelpers, :type => :feature
end
