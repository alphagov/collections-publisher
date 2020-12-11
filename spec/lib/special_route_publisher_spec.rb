require "rails_helper"
require_relative "../../lib/special_route_publisher"

RSpec.describe SpecialRoutePublisher do
  describe "publish" do
    it "calls 'publish' on SpecialRoutePublisher with a route" do
      route = {
        document_type: "answer",
        content_id: SecureRandom.uuid,
        base_path: "/foo",
        locale: "en",
        title: "Title",
        description: "description",
      }

      expect_any_instance_of(GdsApi::PublishingApi::SpecialRoutePublisher)
        .to receive(:publish)
        .with(
          {
            publishing_app: "collections-publisher",
            rendering_app: "collections",
            type: "exact",
            update_type: "major",
          }.merge(route),
        ).at_least(:once)

      SpecialRoutePublisher.new
        .publish(route)
    end
  end

  describe "unpublish" do
    it "calls Publishing API's unpublish method directly" do
      content_id = SecureRandom.uuid
      options = { type: "exact" }

      expect(Services.publishing_api).to receive(:unpublish).with(
        content_id,
        options,
      )

      SpecialRoutePublisher.new
        .unpublish(content_id, options)
    end
  end

  describe "routes" do
    it "should return an array of routes" do
      expect(SpecialRoutePublisher.routes.first).to include(:content_id)
    end
  end
end
