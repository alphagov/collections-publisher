require "rails_helper"

RSpec.describe Coronavirus::ReorderAnnouncementsController do
  include CoronavirusFeatureSteps

  let(:page) { create(:coronavirus_page) }
  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }

  describe "GET Coronavirus reorder announcements page" do
    it "can only be accessed by users with Coronavirus editor permissions" do
      get :index, params: { page_slug: page.slug }
      expect(response).to have_http_status(:success)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      stub_user.permissions = %w[signin]
      get :index, params: { page_slug: page.slug }

      expect(response.status).to eq(403)
    end
  end

  describe "PUT Coronavirus reorder announcements page" do
    let!(:announcement) { create(:announcement, position: 0, page: page) }
    let!(:another_announcement) { create(:announcement, position: 1, page: page) }

    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    it "reorders the announcements" do
      announcement_params = [
        {
          id: announcement.id,
          position: 1,
        },
        {
          id: another_announcement.id,
          position: 0,
        },
      ]

      put :update, params: {
        page_slug: page.slug,
        announcement_order_save: announcement_params.to_json,
      }

      expect(announcement.reload.position).to eq 1
      expect(another_announcement.reload.position).to eq 0
      expect(subject).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "keeps the existing order if submitted without changes" do
      announcement_params = [
        {
          id: announcement.id,
          position: 0,
        },
        {
          id: another_announcement.id,
          position: 1,
        },
      ]

      put :update, params: {
        page_slug: page.slug,
        announcement_order_save: announcement_params.to_json,
      }

      expect(announcement.reload.position).to eq 0
      expect(another_announcement.reload.position).to eq 1
      expect(subject).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "keeps the existing order if updating the draft fails" do
      stub_publishing_api_isnt_available

      announcement_params = [
        {
          id: announcement.id,
          position: 2,
        },
        {
          id: another_announcement.id,
          position: 1,
        },
      ]

      put :update, params: {
        page_slug: page.slug,
        announcement_order_save: announcement_params.to_json,
      }

      expect(announcement.reload.position).to eq 1
      expect(another_announcement.reload.position).to eq 2
      expect(subject).to redirect_to(reorder_coronavirus_page_announcements_path(page.slug))
    end
  end
end
