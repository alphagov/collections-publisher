require "rails_helper"
require "gds_api/publishing_api/special_route_publisher"

RSpec.describe "rake publishing_api:publish_special_route", type: :task do
  before do
    Rails.application.load_tasks
    Rake::Task["publishing_api:publish_special_route"].reenable
  end

  it "finds a configured route by base path and publishes it" do
    expected_payload = {
      base_path: "/eubusiness.de",
      content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
      description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      locale: "de",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      title: "Trade with the UK from 1 January 2021 as a business based in the EU",
      type: "exact",
      update_type: "major",
    }

    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:publish)

    expect_any_instance_of(GdsApi::PublishingApi::SpecialRoutePublisher).to receive(:publish).with(expected_payload)

    Rake::Task["publishing_api:publish_special_route"].invoke("/eubusiness.de")
  end
end
