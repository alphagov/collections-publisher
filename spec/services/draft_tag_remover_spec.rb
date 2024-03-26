require "rails_helper"

RSpec.describe DraftTagRemover do
  before do
    stub_any_publishing_api_call
    publishing_api_has_no_linked_items
  end

  describe "#remove" do
    it "guards against removing published tags" do
      mainstream_browse_page = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))

      expect { DraftTagRemover.new(mainstream_browse_page).remove }.to raise_error(RuntimeError)
    end

    it "guards against removing parent (level 1) Mainstream browse page" do
      mainstream_browse_page = create(:mainstream_browse_page, :draft)

      expect { DraftTagRemover.new(mainstream_browse_page).remove }.to raise_error(RuntimeError)
    end

    it "removes level 2 tag from the database" do
      mainstream_browse_page = create(:mainstream_browse_page, :draft, parent: create(:mainstream_browse_page))

      DraftTagRemover.new(mainstream_browse_page).remove

      expect { mainstream_browse_page.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
