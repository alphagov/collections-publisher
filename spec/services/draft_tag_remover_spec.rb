require 'rails_helper'

RSpec.describe DraftTagRemover do
  before do
    stub_any_publishing_api_call
    publishing_api_has_no_linked_items
    allow(Services.panopticon).to receive(:delete_tag!)
  end

  describe "#remove" do
    it "guards against removing published tags" do
      topic = create(:topic, :published, parent: create(:topic))

      DraftTagRemover.new(topic).remove

      expect(topic.reload).to eql(topic)
    end

    it "guards against removing parent tags" do
      topic = create(:topic, :draft)

      DraftTagRemover.new(topic).remove

      expect(topic.reload).to eql(topic)
    end

    it "won't remove tags with documents tagged to it" do
      topic = create(:topic, :draft, parent: create(:topic))
      publishing_api_has_linked_items(
        topic.content_id,
        items: [
          { link: '/content-page-1' },
          { link: '/content-page-2' },
        ]
      )

      DraftTagRemover.new(topic).remove

      expect(topic.reload).to eql(topic)
    end

    it "removes the tag from the database" do
      topic = create(:topic, :draft, parent: create(:topic))

      DraftTagRemover.new(topic).remove

      expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "removes the tag from panoption" do
      topic = create(:topic, :draft, parent: create(:topic))

      DraftTagRemover.new(topic).remove

      expect(Services.panopticon).to have_received(:delete_tag!)
    end
  end
end
