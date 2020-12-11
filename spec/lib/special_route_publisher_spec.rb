require "rails_helper"
require_relative "../../lib/special_route_publisher"

RSpec.describe SpecialRoutePublisher do
  describe "publish" do
    it "calls 'publish' on the passed 'publisher' argument" do
      publisher = double("GdsApi::PublishingApi::SpecialRoutePublisher")
      expect(publisher).to receive(:publish).with(hash_including({
        publishing_app: "collections-publisher",
        rendering_app: "collections",
        type: "route_type",
        public_updated_at: Time.zone.now.iso8601,
        update_type: "major",
        foo: "bar",
      }))

      SpecialRoutePublisher.new({}, publisher)
        .publish("route_type", { foo: "bar" })
    end
  end

  describe "unpublish" do
    it "calls Publishing API's unpublish method directly" do
      publishing_api = double("Publishing API")
      content_id = SecureRandom.uuid
      options = { foo: "bar" }
      expect(publishing_api).to receive(:unpublish).with(
        content_id,
        options,
      )

      SpecialRoutePublisher.new({ publishing_api: publishing_api })
        .unpublish(content_id, options)
    end
  end

  describe "routes" do
    it "should return a hash" do
      expect(SpecialRoutePublisher.routes).to include(:exact)
    end
  end
end
