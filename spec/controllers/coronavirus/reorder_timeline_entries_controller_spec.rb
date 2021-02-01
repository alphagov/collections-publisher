require "rails_helper"

RSpec.describe Coronavirus::ReorderTimelineEntriesController do
  include CoronavirusFeatureSteps

  let(:coronavirus_page) { create(:coronavirus_page) }

  describe "GET Coronavirus reorder timeline entries page" do
    let(:stub_user) { create :user, name: "Name Surname" }

    it "can only be accessed by users with Coronavirus editor permissions" do
      stub_user.permissions = ["signin", "Coronavirus editor"]
      get :index, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:success)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      get :index, params: { coronavirus_page_slug: coronavirus_page.slug }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PUT Coronavirus reorder timeline entries page" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let!(:second_timeline_entry) { create(:timeline_entry, coronavirus_page: coronavirus_page) }
    let!(:first_timeline_entry) { create(:timeline_entry, coronavirus_page: coronavirus_page) }

    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_coronavirus_publishing_api
    end

    it "reorders the timeline entries" do
      timeline_entry_params = [
        {
          id: first_timeline_entry.id,
          position: 2,
        },
        {
          id: second_timeline_entry.id,
          position: 1,
        },
      ]

      put :update, params: {
        coronavirus_page_slug: coronavirus_page.slug,
        timeline_entry_order_save: timeline_entry_params.to_json,
      }

      expect(first_timeline_entry.reload.position).to eq 2
      expect(second_timeline_entry.reload.position).to eq 1
      expect(response).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "keeps the existing order if submitted without changes" do
      timeline_entry_params = [
        {
          id: first_timeline_entry.id,
          position: 1,
        },
        {
          id: second_timeline_entry.id,
          position: 2,
        },
      ]

      put :update, params: {
        coronavirus_page_slug: coronavirus_page.slug,
        timeline_entry_order_save: timeline_entry_params.to_json,
      }

      expect(first_timeline_entry.reload.position).to eq 1
      expect(second_timeline_entry.reload.position).to eq 2
      expect(response).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "keeps the existing order if updating the draft fails" do
      stub_publishing_api_isnt_available

      timeline_entry_params = [
        {
          id: first_timeline_entry.id,
          position: 2,
        },
        {
          id: second_timeline_entry.id,
          position: 1,
        },
      ]

      put :update, params: {
        coronavirus_page_slug: coronavirus_page.slug,
        timeline_entry_order_save: timeline_entry_params.to_json,
      }

      expect(first_timeline_entry.reload.position).to eq 1
      expect(second_timeline_entry.reload.position).to eq 2
      expect(response).to redirect_to(reorder_coronavirus_page_timeline_entries_path(coronavirus_page.slug))
    end
  end
end
