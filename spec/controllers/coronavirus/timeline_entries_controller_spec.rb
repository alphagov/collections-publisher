require "rails_helper"

RSpec.describe Coronavirus::TimelineEntriesController do
  include CoronavirusFeatureSteps

  let(:stub_user) { create :user, name: "Name Surname" }
  let(:page) { create :coronavirus_page, :landing }

  describe "GET /coronavirus/:page_slug/timeline_entries/new" do
    it "can only be accessed by users with Coronavirus editor permissions" do
      stub_user.permissions << "Coronavirus editor"
      get :new, params: { page_slug: page.slug }

      expect(response).to have_http_status(:ok)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      get :new, params: { page_slug: page.slug }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /coronavirus/:page_slug/timeline_entries" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let(:heading) { Faker::Lorem.sentence }
    let(:content) { Faker::Lorem.sentence }
    let(:timeline_entry_params) do
      {
        heading: heading,
        content: content,
      }
    end

    before do
      stub_coronavirus_landing_page_content(page)
      stub_any_publishing_api_call
    end

    it "saves a new timeline entry" do
      post :create,
           params: {
             page_slug: page.slug,
             timeline_entry: timeline_entry_params,
           }

      timeline_entry = page.timeline_entries.last

      expect(timeline_entry.heading).to eq(heading)
      expect(timeline_entry.content).to eq(content)
    end

    it "redirects to coronavirus page on success" do
      post :create,
           params: {
             page_slug: page.slug,
             timeline_entry: timeline_entry_params,
           }

      expect(response).to redirect_to(coronavirus_page_path(page.slug))
    end
  end

  describe "GET /coronavirus/:page_slug/timeline_entries/:id/edit" do
    let(:timeline_entry) { create(:timeline_entry, page: page) }

    it "can only be accessed by users with Coronavirus editor permissions" do
      stub_user.permissions << "Coronavirus editor"
      get :edit,
          params: {
            id: timeline_entry.id,
            page_slug: page.slug,
          }

      expect(response).to have_http_status(:ok)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      get :edit,
          params: {
            id: timeline_entry.id,
            page_slug: page.slug,
          }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /coronavirus/:page_slug/timeline_entries/:id" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let(:timeline_entry) { create(:timeline_entry, page: page) }

    let(:updated_timeline_entry_params) do
      {
        heading: "Updated heading",
        content: "##Updated content",
      }
    end

    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    it "updates the timeline entry" do
      patch :update,
            params: {
              id: timeline_entry.id,
              page_slug: page.slug,
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
              page_slug: page.slug,
              timeline_entry: updated_timeline_entry_params,
            }

      expect(response).to redirect_to(coronavirus_page_path(page.slug))
    end
  end

  describe "DELETE /coronavirus/:page_slug/timeline_entries/:id" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let!(:timeline_entry) { create(:timeline_entry, page: page, heading: "Skywalker") }

    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    it "redirects to the coronavirus page" do
      delete :destroy,
             params: {
               id: timeline_entry.id,
               page_slug: page.slug,
             }

      expect(response).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "deletes the timeline entry" do
      delete :destroy,
             params: {
               id: timeline_entry.id,
               page_slug: page.slug,
             }

      expect(page.reload.timeline_entries.count).to eq(0)
    end

    it "doesn't delete the timeline_entry if draft_updater fails" do
      stub_publishing_api_isnt_available
      create(:timeline_entry, page: page, heading: "Amidala")

      params = {
        id: timeline_entry.id,
        page_slug: page.slug,
      }

      expect { delete :destroy, params: params }
        .to_not(change { page.reload.timeline_entries.to_a })
    end
  end
end
