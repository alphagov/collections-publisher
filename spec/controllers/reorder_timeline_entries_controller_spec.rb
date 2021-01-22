require "rails_helper"

RSpec.describe ReorderTimelineEntriesController do
  let(:coronavirus_page) { create(:coronavirus_page) }
  let(:stub_user) { create :user, name: "Name Surname" }

  describe "Coronavirus reorder timeline entries page" do
    it "can only be accessed by users with Coronavirus editor permissions" do
      stub_user.permissions = ["signin", "Coronavirus editor", "Unreleased feature"]
      get :index, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:success)
    end

    it "cannot be accessed by users without Unreleased feature permissions" do
      stub_user.permissions << "Coronavirus editor"
      get :index, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:forbidden)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      stub_user.permissions << "Unreleased feature"
      get :index, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
