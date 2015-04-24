require "spec_helper"

RSpec.describe PublishingAPINotifier do
  let(:publishing_api) { double(:publishing_api, put_content_item: nil) }

  before do
    allow(CollectionsPublisher).to receive(:services).with(:publishing_api).and_return(publishing_api)
  end

  describe "send_to_publishing_api" do
    let(:tag) { create(:topic, :published) }
    let(:presenter) { instance_double("TagPresenter", :base_path => "/foo", :render_for_publishing_api => :presented_details) }
    before :each do
      allow(TagPresenter).to receive(:presenter_for).and_return(presenter)
    end

    it "constructs a presenter for the given tag" do
      expect(TagPresenter).to receive(:presenter_for).with(tag).and_return(presenter)
      PublishingAPINotifier.send_to_publishing_api(tag)
    end

    it "sends the presented details to the publishing-api" do
      expect(publishing_api).to receive(:put_content_item).with("/foo", :presented_details)
      PublishingAPINotifier.send_to_publishing_api(tag)
    end

    it "clears the dirty state on the tag" do
      tag.mark_as_dirty!

      PublishingAPINotifier.send_to_publishing_api(tag)
      tag.reload
      expect(tag).not_to be_dirty
    end

    it "raises an error if a draft tag is given" do
      allow(tag).to receive(:published?).and_return(false)
      expect(publishing_api).not_to receive(:send_to_publishing_api)

      expect {
        PublishingAPINotifier.send_to_publishing_api(tag)
      }.to raise_error
    end
  end
end
