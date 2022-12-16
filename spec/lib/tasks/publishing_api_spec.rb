require "rails_helper"
require "gds_api/publishing_api/special_route_publisher"

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

RSpec.describe "rake publishing_api:send_published_tags_with_lists", type: :task do
  let(:list_republisher) { instance_double(ListRepublisher) }

  let(:level_one_tag) { create(:tag, :published, parent: nil) }
  let(:draft_level_two_tag) { create(:tag, parent: level_one_tag) }
  let(:published_level_two_tag) { create(:tag, :published, parent: level_one_tag) }

  before do
    Rake::Task["publishing_api:send_published_tags_with_lists"].reenable
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
    allow(ListRepublisher).to receive(:new).and_return(list_republisher)
    allow(list_republisher).to receive(:republish_tags)
  end

  it "republishes only published level two tags " do
    Rake::Task["publishing_api:send_published_tags_with_lists"].invoke

    expect(list_republisher).to have_received(:republish_tags).with([published_level_two_tag])
  end
end
