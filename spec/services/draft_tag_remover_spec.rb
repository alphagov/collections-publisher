require "rails_helper"

RSpec.describe DraftTagRemover do
  before do
    stub_any_publishing_api_call
    publishing_api_has_no_linked_items
  end

  describe "#remove" do
    it "guards against removing published tags" do
      topic = create(:topic, :published, parent: create(:topic))

      expect { DraftTagRemover.new(topic).remove }.to raise_error(RuntimeError)
    end

    it "guards against removing parent (level 1) tags" do
      topic = create(:topic, :draft)

      expect { DraftTagRemover.new(topic).remove }.to raise_error(RuntimeError)
    end

    it "removes the tag from the database" do
      topic = create(:topic, :draft, parent: create(:topic))

      DraftTagRemover.new(topic).remove

      expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
