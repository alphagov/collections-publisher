require "rails_helper"

RSpec.describe TimelineEntriesController do
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
      setup_github_data
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

      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
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

  def setup_github_data
    raw_content = File.read(Rails.root.join("spec/fixtures/coronavirus_landing_page.yml"))
    stub_request(:get, /#{coronavirus_page.raw_content_url}\?cache-bust=\d+/)
      .to_return(status: 200, body: raw_content)
  end
end
