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
      description: "Das Vereinigte Königreich ist aus der EU ausgetreten. Am 31. Dezember 2020 wird das Vereinigte Königreich den EU-Binnenmarkt und die Zollunion verlassen. Ab 1. Januar 2021 ändern sich die Regeln für den Handel mit dem Vereinigten Königreich.",
      locale: "de",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      title: "Handel mit dem Vereinigten Königreich ab 1. Januar 2021 als Unternehmen mit Sitz in der EU",
      type: "exact",
      update_type: "major",
    }

    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:publish)

    expect_any_instance_of(GdsApi::PublishingApi::SpecialRoutePublisher).to receive(:publish).with(expected_payload)

    Rake::Task["publishing_api:publish_special_route"].invoke("/eubusiness.de")
  end
end
