require "rails_helper"
require_relative "../../lib/special_route_publisher"

RSpec.describe SpecialRoutePublisher do
  describe "#publish" do
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
        )

      described_class.new
        .publish(route)
    end
  end

  describe "#unpublish" do
    it "calls Publishing API's unpublish method directly" do
      content_id = SecureRandom.uuid
      options = { type: "exact" }

      expect(Services.publishing_api).to receive(:unpublish).with(
        content_id,
        options,
      )

      described_class.new
        .unpublish(content_id, options)
    end
  end

  describe ".routes" do
    it "should return an array of routes" do
      expect(described_class.routes.first).to include(:content_id)
    end
  end

  describe ".find_route" do
    it "returns a route by its base_path" do
      path = "/eubusiness"
      response = described_class.find_route(path)
      expect(response).to include(base_path: path)
    end
  end
end
