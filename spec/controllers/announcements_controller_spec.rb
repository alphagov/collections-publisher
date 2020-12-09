require "rails_helper"

RSpec.describe AnnouncementsController, type: :controller do
  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :landing }
  let!(:live_stream) { create :live_stream, :without_validations }
  let(:title) { Faker::Lorem.sentence }
  let(:path) { "/government/foo/vader/baby/yoda" }
  let(:published_at) { { "day" => "12", "month" => "12", "year" => "1980" } }

  describe "GET /coronavirus/:coronavirus_page_slug/announcements/new" do
    it "renders successfully if the user has unreleased feature permission" do
      stub_user.permissions << "Unreleased feature"
      get :new, params: { coronavirus_page_slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end

    it "does not render successfully if the user does not have Coronavirus editor permissions" do
      create :user, name: "Name Surname"
      get :new, params: { coronavirus_page_slug: coronavirus_page.slug }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /coronavirus/:coronavirus_page_slug/announcements" do
    before do
      stub_user.permissions << "Unreleased feature"
      setup_github_data
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
      stub_user.permissions << "Unreleased feature"
      setup_github_data
      stub_coronavirus_publishing_api
    end

    let(:announcement) { create(:announcement, coronavirus_page: coronavirus_page) }

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
      announcement
      expect { subject }.to change { Announcement.count }.by(-1)
    end
  end
  def setup_github_data
    raw_content = File.read(Rails.root.join("spec/fixtures/coronavirus_landing_page.yml"))
    stub_request(:get, /#{coronavirus_page.raw_content_url}\?cache-bust=\d+/)
      .to_return(status: 200, body: raw_content)
  end
end
