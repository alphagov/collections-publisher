require 'rails_helper'

RSpec.describe ReviewController do
  describe "GET submit for 2i page" do
    let(:step_by_step_page) { create(:draft_step_by_step_page) }

    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    it "can only be accessed by users with GDS editor and Unreleased feature permissions" do
      stub_user.permissions = ["signin", "GDS Editor", "Unreleased feature"]
      get :submit_for_2i, params: { step_by_step_page_id: step_by_step_page.id }

      expect(response.status).to eq(200)
    end

    it "cannot be accessed by users with only GDS editor permissions" do
      stub_user.permissions << "GDS Editor"
      get :submit_for_2i, params: { step_by_step_page_id: step_by_step_page.id }

      expect(response.status).to eq(403)
    end

    it "cannot be accessed by users with neither GDS editor and Unreleased feature permissions" do
      stub_user.permissions = %w(signin)
      get :submit_for_2i, params: { step_by_step_page_id: step_by_step_page.id }

      expect(response.status).to eq(403)
    end
  end
end
