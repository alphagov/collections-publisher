require 'rails_helper'

RSpec.describe InternalChangeNotesController, type: :controller do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  describe "POST #create" do
    it "creates an InternalChangeNote" do
      stub_user.name = "Test author"
      create(:step_by_step_page, id: 0)
      expect(InternalChangeNote).to receive(:create)
      post :create, params: { step_by_step_page_id: 0, internal_change_note: { description: "Test description" } }
    end
    it "saves it to the database" do
      stub_user.name = "Test author"
      create(:step_by_step_page, id: 0)
      post :create, params: { step_by_step_page_id: 0, internal_change_note: { description: "Test description" } }
      expect(InternalChangeNote.first.author).to eql "Test author"
    end
  end
end
