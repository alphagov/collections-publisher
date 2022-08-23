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

    it "guards against removing parent (level 1) Mainstream browse page" do
      topic = create(:mainstream_browse_page, :draft)

      expect { DraftTagRemover.new(topic).remove }.to raise_error(RuntimeError)
    end

    it "guards against removing parent (level 1) Topic which has children" do
      topic = create(:topic, :draft, children: [create(:topic, :draft)])

      expect { DraftTagRemover.new(topic).remove }.to raise_error(RuntimeError)
    end

    it "removes level 2 tag from the database" do
      topic = create(:topic, :draft, parent: create(:topic))

      DraftTagRemover.new(topic).remove

      expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "removes level 1 topic from the database as long as it has no children" do
      topic = create(:topic, :draft, children: [])

      DraftTagRemover.new(topic).remove

      expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
