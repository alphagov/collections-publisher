require "rails_helper"

RSpec.describe Coronavirus::AnnouncementsController do
  include CoronavirusFeatureSteps

  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :landing }
  let!(:announcement) { create :announcement, coronavirus_page: coronavirus_page }
  let(:title) { Faker::Lorem.sentence }
  let(:path) { "/government/foo/vader/baby/yoda" }
  let(:published_at) { { "day" => "12", "month" => "12", "year" => "1980" } }

  describe "GET /coronavirus/:coronavirus_page_slug/announcements/new" do
    it "does not render successfully if the user does not have Coronavirus editor permissions" do
      stub_user.permissions = %w[signin]
      get :new, params: { coronavirus_page_slug: coronavirus_page.slug }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /coronavirus/:coronavirus_page_slug/announcements" do
    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_coronavirus_publishing_api
    end

    let(:announcement_params) do
      {
        title: title,
        path: path,
        published_at: published_at,
      }
    end

    it "redirects to coronavirus page on success" do
      post :create, params: { coronavirus_page_slug: coronavirus_page.slug, announcement: announcement_params }
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
      expect(flash.now[:errors]).to be_nil
    end

    it "adds attributes to new announcement" do
      post :create, params: { coronavirus_page_slug: coronavirus_page.slug, announcement: announcement_params }
      published_at_time = Time.zone.local(published_at["year"], published_at["month"], published_at["day"])
      announcement = coronavirus_page.announcements.last
      expect(announcement.title).to eq(title)
      expect(announcement.path).to eq(path)
      expect(announcement.published_at).to eq(published_at_time)
    end
  end

  describe "DELETE /coronavirus/:coronavirus_page_slug/announcements/:id" do
    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_coronavirus_publishing_api
    end

    let(:announcement_params) do
      {
        id: announcement,
        coronavirus_page_slug: coronavirus_page.slug,
      }
    end

    subject { delete :destroy, params: announcement_params }

    it "redirects to the coronavirus page" do
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "deletes the announcement" do
      expect { subject }.to change { Announcement.count }.by(-1)
    end

    it "doesn't delete the announcement if draft_updater fails" do
      stub_publishing_api_isnt_available

      expect { subject }.to_not(change { coronavirus_page.reload.announcements.to_a })
    end
  end

  describe "GET /coronavirus/:coronavirus_page_slug/announcements/:id/edit" do
    it "renders successfully" do
      get :edit, params: { id: announcement, coronavirus_page_slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end

    it "does not render successfully if the user does not have Coronavirus editor permissions" do
      stub_user.permissions = %w[signin]
      get :new, params: { coronavirus_page_slug: coronavirus_page.slug }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /coronavirus/:coronavirus_page_slug/announcement" do
    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_coronavirus_publishing_api
    end

    let(:updated_announcement_params) do
      {
        title: "Updated title",
        path: "/updated/path",
        published_at: published_at,
      }
    end

    let(:params) do
      {
        id: announcement.id,
        coronavirus_page_slug: coronavirus_page.slug,
        announcement: updated_announcement_params,
      }
    end

    subject { patch :update, params: params }

    it "redirects to coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "updates the announcements" do
      expect { subject }.not_to(change { Announcement.count })
    end

    it "changes the attributes of the announcement" do
      subject
      published_at_time = Time.zone.local(updated_announcement_params[:published_at]["year"], updated_announcement_params[:published_at]["month"], updated_announcement_params[:published_at]["day"])
      announcement.reload
      expect(announcement.title).to eq(updated_announcement_params[:title])
      expect(announcement.path).to eq(updated_announcement_params[:path])
      expect(announcement.published_at).to eq(published_at_time)
    end
  end
end
