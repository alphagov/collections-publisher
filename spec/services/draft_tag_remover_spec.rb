require 'rails_helper'

RSpec.describe DraftTagRemover do
  include ContentStoreHelpers

  before do
    stub_content_store!
    stub_any_call_to_rummager_with_documents([])
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
      stub_any_call_to_rummager_with_documents([
        { link: '/content-page-1' },
        { link: '/content-page-2' },
      ])

      DraftTagRemover.new(topic).remove

      expect(topic.reload).to eql(topic)
    end

    it "removes the tag from the database" do
      topic = create(:topic, :draft, parent: create(:topic))

      DraftTagRemover.new(topic).remove

      expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "pushes a gone item to the content-store" do
      topic = create(:topic, :draft, slug: 'bar', parent: create(:topic, slug: 'foo'))

      DraftTagRemover.new(topic).remove

      expect(stubbed_content_store).to have_draft_content_item_slug('/topic/foo/bar')
      expect(stubbed_content_store.last_updated_item).to be_valid_against_schema('gone')
    end
  end
end
