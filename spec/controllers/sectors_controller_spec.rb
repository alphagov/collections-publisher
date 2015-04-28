require "rails_helper"

RSpec.describe SectorsController do

  describe "#publish" do
    let(:topic) { create(:topic, :published) }
    let(:subtopic) { create(:topic, :published, :parent => topic) }

    before do
      allow(PublishingAPINotifier).to receive(:send_to_publishing_api)
    end

    it "notifies the publishing API" do
      expect(PublishingAPINotifier).to receive(:send_to_publishing_api).with(subtopic)

      put :publish, sector_id: subtopic.panopticon_slug
    end

    it "marks the sector as clean" do
      put :publish, sector_id: subtopic.panopticon_slug

      subtopic.reload
      expect(subtopic).not_to be_dirty
    end
  end
end
