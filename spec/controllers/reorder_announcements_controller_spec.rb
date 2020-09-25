require "rails_helper"

RSpec.describe ReorderAnnouncementsController, type: :controller do
  let(:coronavirus_page) { create(:coronavirus_page) }
  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }

  describe "Coronavirus reorder announcements page" do
    it "can only be accessed by users with Coronavirus editor permissions" do
      get :index, params: { coronavirus_page_slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      stub_user.permissions = %w[signin]
      get :index, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response.status).to eq(403)
    end
  end
end
