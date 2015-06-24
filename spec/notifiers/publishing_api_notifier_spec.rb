require "rails_helper"

RSpec.describe PublishingAPINotifier do
  let(:publishing_api) { instance_double("GdsApi::PublishingApi", :put_content_item => nil, :put_draft_content_item => nil) }

  before do
    allow(CollectionsPublisher).to receive(:services).with(:publishing_api).and_return(publishing_api)
  end

  describe "send_to_publishing_api" do
    let(:presenter) { instance_double("TagPresenter", :base_path => "/foo", :render_for_publishing_api => :presented_details) }
    before :each do
      allow(TagPresenter).to receive(:presenter_for).and_return(presenter)
    end

    context "for a draft tag" do
      let(:tag) { create(:topic, :draft) }

      it "constructs a presenter for the given tag" do
        expect(TagPresenter).to receive(:presenter_for).with(tag).and_return(presenter)
        PublishingAPINotifier.send_to_publishing_api(tag)
      end

      it "sends the presented details as a draft to the publishing-api" do
        expect(publishing_api).to receive(:put_draft_content_item).with("/foo", :presented_details)
        expect(publishing_api).not_to receive(:put_content_item)

        PublishingAPINotifier.send_to_publishing_api(tag)
      end
    end

    context "for a published tag" do
      let(:tag) { create(:topic, :published) }

      it "constructs a presenter for the given tag" do
        expect(TagPresenter).to receive(:presenter_for).with(tag).and_return(presenter)
        PublishingAPINotifier.send_to_publishing_api(tag)
      end

      it "sends the presented details to the publishing-api" do
        expect(publishing_api).to receive(:put_content_item).with("/foo", :presented_details)
        PublishingAPINotifier.send_to_publishing_api(tag)
      end
    end
  end
end
