require "rails_helper"
require "gds_api/publishing_api/special_route_publisher"
require "gds_api/test_helpers/content_store"

RSpec.describe "rake publishing_api:publish_special_route", type: :task do
  before do
    Rake::Task["publishing_api:publish_special_route"].reenable
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  it "finds a configured route by base path and publishes it" do
    Rake::Task["publishing_api:publish_special_route"].invoke("/eubusiness.it")

    assert_publishing_api_put_content(
      "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
      request_json_includes(
        "base_path" => "/eubusiness.it",
      ),
    )

    assert_publishing_api_publish("bb986a97-3b8c-4b1a-89bf-2a9f46be9747")
  end
end

RSpec.describe "rake publishing_api:update_redirect", type: :task do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::ContentItemHelpers

  before do
    Rake::Task["publishing_api:update_redirect"].reenable
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  context "when correct args are passed in" do
    let(:redirect_url) { "/i-am-the-redirect" }
    let(:content_id) { "i123" }

    it "updates the redirect for an archived tag" do
      stub_content_store_has_item(redirect_url)
      topic = create(:topic, :archived, content_id:)
      create(:redirect_route, from_base_path: topic.base_path, tag: topic)

      Rake::Task["publishing_api:update_redirect"].invoke(content_id, redirect_url)

      assert_publishing_api_put_content(
        content_id,
        request_json_includes(
          "base_path" => topic.base_path,
          "schema_name" => "redirect",
          "redirects" => [
            {
              "path" => topic.base_path,
              "destination" => redirect_url,
              "type" => "exact",
            },
          ],
        ),
      )
      assert_publishing_api_publish(content_id)
    end
  end

  context "when invalid args are passed in" do
    let(:invalid_redirect_url) { "/i-contain-a-typo" }
    let(:valid_redirect_url) { "/i-am-the-redirect" }

    let(:archived_content_id) { "i123" }
    let(:published_content_id) { "abce1" }

    it "raises an error if no content item lives at the provided redirect_url" do
      stub_content_store_does_not_have_item(invalid_redirect_url)

      archived_topic = create(:topic, :archived, content_id: archived_content_id)
      create(:redirect_route, from_base_path: archived_topic.base_path, tag: archived_topic)

      expect { Rake::Task["publishing_api:update_redirect"].invoke(archived_content_id, invalid_redirect_url) }.to raise_error(GdsApi::ContentStore::ItemNotFound)
    end

    it "raises an error if we attempt to update the url of a published tag" do
      stub_content_store_has_item(valid_redirect_url)

      create(:topic, content_id: published_content_id)
      expected_message = "This task can only be used for archived topics"

      expect { Rake::Task["publishing_api:update_redirect"].invoke(published_content_id, valid_redirect_url) }.to raise_error(expected_message)
    end

    it "raises an error if we attempt to update the url of a tag that is not a Topic" do
      stub_content_store_has_item(valid_redirect_url)

      create(:mainstream_browse_page, content_id: published_content_id)
      expected_message = "This task can only be used for archived topics"

      expect { Rake::Task["publishing_api:update_redirect"].invoke(published_content_id, valid_redirect_url) }.to raise_error(expected_message)
    end
  end
end
