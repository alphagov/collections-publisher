require 'gds_api/test_helpers/panopticon'

module PanopticonHelpers
  include GdsApi::TestHelpers::Panopticon

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
    payload[:parent_id] ||= nil
    payload = Hash[payload.sort]
    request = stub_panopticon_tag_creation(payload)
    expect(request).to have_been_requested
  end

  def assert_tag_updated_in_panopticon(payload)
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
