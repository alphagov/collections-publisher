require "rails_helper"

RSpec.describe Coronavirus::ReorderTimelineEntriesController do
  include CoronavirusFeatureSteps

  let(:page) { create(:coronavirus_page) }

  describe "GET Coronavirus reorder timeline entries page" do
    let(:stub_user) { create :user, name: "Name Surname" }

    it "can only be accessed by users with Coronavirus editor permissions" do
      stub_user.permissions = ["signin", "Coronavirus editor"]
      get :index, params: { page_slug: page.slug }

      expect(response).to have_http_status(:success)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      get :index, params: { page_slug: page.slug }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PUT Coronavirus reorder timeline entries page" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let!(:second_timeline_entry) { create(:coronavirus_timeline_entry, page: page) }
    let!(:first_timeline_entry) { create(:coronavirus_timeline_entry, page: page) }

    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    it "reorders the timeline entries" do
      timeline_entry_params = {
        first_timeline_entry.id => 2,
        second_timeline_entry.id => 1,
      }

      put :update, params: {
        page_slug: page.slug,
        timeline_entry_order_save: timeline_entry_params,
      }

      expect(first_timeline_entry.reload.position).to eq 2
      expect(second_timeline_entry.reload.position).to eq 1
      expect(response).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "keeps the existing order if submitted without changes" do
      timeline_entry_params = {
        first_timeline_entry.id => 1,
        second_timeline_entry.id => 2,
      }

      put :update, params: {
        page_slug: page.slug,
        timeline_entry_order_save: timeline_entry_params,
      }

      expect(first_timeline_entry.reload.position).to eq 1
      expect(second_timeline_entry.reload.position).to eq 2
      expect(response).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "keeps the existing order if updating the draft fails" do
      stub_publishing_api_isnt_available

      timeline_entry_params = {
        first_timeline_entry.id => 2,
        second_timeline_entry.id => 1,
      }

      put :update, params: {
        page_slug: page.slug,
        timeline_entry_order_save: timeline_entry_params,
      }

      expect(first_timeline_entry.reload.position).to eq 1
      expect(second_timeline_entry.reload.position).to eq 2
      expect(response).to redirect_to(reorder_coronavirus_page_timeline_entries_path(page.slug))
    end

    context "when a user manually enters an unconventional ordering approach" do
      it "applies our expected incremental ordering" do
        timeline_entry_params = {
          first_timeline_entry.id => 50,
          second_timeline_entry.id => 100,
        }

        put :update, params: {
          page_slug: page.slug,
          timeline_entry_order_save: timeline_entry_params,
        }

        expect(first_timeline_entry.reload.position).to eq 1
        expect(second_timeline_entry.reload.position).to eq 2
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end
  end
end
