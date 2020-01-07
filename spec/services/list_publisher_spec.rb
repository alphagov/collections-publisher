require "rails_helper"

RSpec.describe ListPublisher do
  describe "#perform" do
    before { allow(PublishingAPINotifier).to receive(:notify) }

    it "updates the groups-data to be sent to the content store" do
      topic = create(:topic)
      create(:list, name: "A Listname", tag: topic)

      ListPublisher.new(topic).perform

      expect(topic.published_groups).to eql([{ "name" => "A Listname", "contents" => [] }])
    end

    it "sends the updated information to the content-store" do
      topic = create(:topic)

      ListPublisher.new(topic).perform

      expect(PublishingAPINotifier).to have_received(:notify)
    end

    it "clears the dirty flag from tag" do
      topic = create(:topic, dirty: true)

      ListPublisher.new(topic).perform

      expect(topic).not_to be_dirty
    end
  end
end
