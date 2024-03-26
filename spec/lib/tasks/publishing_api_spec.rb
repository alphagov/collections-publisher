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
