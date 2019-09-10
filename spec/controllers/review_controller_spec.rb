require 'rails_helper'

RSpec.describe ReviewController do
  describe "#submit_for_2i" do
    let(:step_by_step_page) { create(:draft_step_by_step_page) }

    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    describe "GET submit for 2i page" do
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

      it "cannot be accessed by users with

       neither GDS editor and Unreleased feature permissions" do
        stub_user.permissions = %w(signin)
        get :submit_for_2i, params: { step_by_step_page_id: step_by_step_page.id }

        expect(response.status).to eq(403)
      end
    end

    describe "POST submit for 2i" do
      before do
        stub_user.permissions = ["signin", "GDS Editor", "Unreleased feature"]
      end

      it "sets status to submit_for_2i" do
        post :submit_for_2i, params: { step_by_step_page_id: step_by_step_page.id }

        step_by_step_page.reload

        expect(step_by_step_page.status).to eq("submitted_for_2i")
        expect(step_by_step_page.review_requester_id).to eq(stub_user.uid)
      end
    end
  end
end
