require "rails_helper"

RSpec.describe TimelineEntriesController do
  describe "GET /coronavirus/:coronavirus_page_slug/timeline_entries/new" do
    let(:stub_user) { create :user, name: "Name Surname" }
    let(:coronavirus_page) { create :coronavirus_page, :landing }

    it "can only be accessed by users with Coronavirus editor and Unreleased feature permissions" do
      stub_user.permissions = ["signin", "Coronavirus editor", "Unreleased feature"]
      get :new, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:ok)
    end

    it "cannot be accessed by users without Unreleased feature permissions" do
      stub_user.permissions << "Coronavirus editor"
      get :new, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:forbidden)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      stub_user.permissions << "Unreleased feature"
      get :new, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
