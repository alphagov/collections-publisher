require "rails_helper"

RSpec.describe InternalChangeNotesController, type: :controller do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    stub_user.name = "Test author"
  end

  describe "POST #create" do
    it "creates an InternalChangeNote" do
      create(:step_by_step_page, id: 0)
      expect(InternalChangeNote).to receive(:create!)
      post :create, params: { step_by_step_page_id: 0, internal_change_note: { description: "Test description" } }
    end
    it "saves it to the database" do
      create(:step_by_step_page, id: 0)
      post :create, params: { step_by_step_page_id: 0, internal_change_note: { description: "Test description" } }
      expect(InternalChangeNote.first.author).to eql "Test author"
      expect(InternalChangeNote.first.edition_number).to be nil
      expect(InternalChangeNote.first.headline).to eql "Internal note"
      expect(InternalChangeNote.first.description).to eql "Test description"
    end

    it "saves a change note with an edition_number for a published version" do
      published_step_by_step_page = create(:published_step_by_step_page)
      published_step_by_step_page.mark_as_published

      allow(Services.publishing_api).to receive(:get_content).with(published_step_by_step_page.content_id).and_return(
        state_history: {
          "3" => "published",
          "2" => "superseded",
          "1" => "superseded",
        },
      )

      post :create, params: {
        step_by_step_page_id: published_step_by_step_page.id,
        internal_change_note: {
          description: "Another change note",
        },
      }

      change_notes = published_step_by_step_page.internal_change_notes
      expect(change_notes.last.edition_number).to eq(3)
    end
  end
end
