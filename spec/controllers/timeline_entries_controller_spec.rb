require "rails_helper"

RSpec.describe TimelineEntriesController do
  include CoronavirusFeatureSteps

  let(:stub_user) { create :user, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :landing }

  describe "GET /coronavirus/:coronavirus_page_slug/timeline_entries/new" do
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

  describe "POST /coronavirus/:coronavirus_page_slug/timeline_entries" do
    let(:heading) { Faker::Lorem.sentence }
    let(:content) { Faker::Lorem.sentence }
    let(:timeline_entry_params) do
      {
        heading: heading,
        content: content,
      }
    end

    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_any_publishing_api_call
      stub_user.permissions = ["signin", "Coronavirus editor", "Unreleased feature"]
    end

    it "saves a new timeline entry" do
      post :create,
           params: {
             coronavirus_page_slug: coronavirus_page.slug,
             timeline_entry: timeline_entry_params,
           }

      timeline_entry = coronavirus_page.timeline_entries.last

      expect(timeline_entry.heading).to eq(heading)
      expect(timeline_entry.content).to eq(content)
    end

    it "redirects to coronavirus page on success" do
      post :create,
           params: {
             coronavirus_page_slug: coronavirus_page.slug,
             timeline_entry: timeline_entry_params,
           }

      expect(response).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end
  end

  describe "GET /coronavirus/:coronavirus_page_slug/timeline_entries/:id/edit" do
    let(:timeline_entry) { create(:timeline_entry, coronavirus_page: coronavirus_page) }

    it "can only be accessed by users with Coronavirus editor and Unreleased feature permissions" do
      stub_user.permissions = ["signin", "Coronavirus editor", "Unreleased feature"]
      get :edit,
          params: {
            id: timeline_entry.id,
            coronavirus_page_slug: coronavirus_page.slug,
          }

      expect(response).to have_http_status(:ok)
    end

    it "cannot be accessed by users without Unreleased feature permissions" do
      stub_user.permissions << "Coronavirus editor"
      get :edit,
          params: {
            id: timeline_entry.id,
            coronavirus_page_slug: coronavirus_page.slug,
          }

      expect(response).to have_http_status(:forbidden)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      stub_user.permissions << "Unreleased feature"
      get :edit,
          params: {
            id: timeline_entry.id,
            coronavirus_page_slug: coronavirus_page.slug,
          }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /coronavirus/:coronavirus_page_slug/timeline_entries/:id" do
    let(:timeline_entry) { create(:timeline_entry, coronavirus_page: coronavirus_page) }

    let(:updated_timeline_entry_params) do
      {
        heading: "Updated heading",
        content: "##Updated content",
      }
    end

    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_coronavirus_publishing_api
      stub_user.permissions = ["signin", "Coronavirus editor", "Unreleased feature"]
    end

    it "updates the timeline entry" do
      patch :update,
            params: {
              id: timeline_entry.id,
              coronavirus_page_slug: coronavirus_page.slug,
              timeline_entry: updated_timeline_entry_params,
            }

      timeline_entry.reload
      expect(timeline_entry.heading).to eq(updated_timeline_entry_params[:heading])
      expect(timeline_entry.content).to eq(updated_timeline_entry_params[:content])
    end

    it "redirects to coronavirus page on success" do
      patch :update,
            params: {
              id: timeline_entry.id,
              coronavirus_page_slug: coronavirus_page.slug,
              timeline_entry: updated_timeline_entry_params,
            }

      expect(response).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end
  end

  describe "DELETE /coronavirus/:coronavirus_page_slug/timeline_entries/:id" do
    let!(:timeline_entry) { create(:timeline_entry, coronavirus_page: coronavirus_page, heading: "Skywalker") }

    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_coronavirus_publishing_api
      stub_user.permissions = ["signin", "Coronavirus editor", "Unreleased feature"]
    end

    it "redirects to the coronavirus page" do
      delete :destroy,
             params: {
               id: timeline_entry.id,
               coronavirus_page_slug: coronavirus_page.slug,
             }

      expect(response).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "deletes the timeline entry" do
      delete :destroy,
             params: {
               id: timeline_entry.id,
               coronavirus_page_slug: coronavirus_page.slug,
             }

      expect(coronavirus_page.reload.timeline_entries.count).to eq(0)
    end

    it "doesn't delete the timeline_entry if draft_updater fails" do
      stub_publishing_api_isnt_available
      create(:timeline_entry, coronavirus_page: coronavirus_page, heading: "Amidala")

      params = {
        id: timeline_entry.id,
        coronavirus_page_slug: coronavirus_page.slug,
      }

      expect { delete :destroy, params: params }
        .to_not(change { coronavirus_page.reload.timeline_entries.to_a })
    end
  end
end
