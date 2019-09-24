require "rails_helper"

RSpec.describe TagPublisher do
  describe "#publish" do
    it "doesn't save to the database when an API call fails" do
      tag = create(:topic, parent: create(:topic))
      allow(PublishingAPINotifier).to receive(:notify).and_raise(RuntimeError)

      expect { TagPublisher.new(tag).publish }.to raise_error(RuntimeError)
      tag.reload

      expect(tag.published?).to be(false)
    end
  end
end
