require "rails_helper"

RSpec.describe Coronavirus::GithubChangesController do
  include CoronavirusFeatureSteps

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create(:coronavirus_page, slug: "landing") }

  before do
    stub_coronavirus_landing_page_content(coronavirus_page)
    stub_coronavirus_publishing_api
  end

  describe "GET /coronavirus/:slug/github_changes" do
    it "renders page successfuly" do
      get :index, params: { slug: coronavirus_page.slug }

      expect(response).to have_http_status(:success)
    end

    it "does not render successfully if the user does not have Coronavirus editor permissions" do
      stub_user.permissions = %w[signin]
      get :index, params: { slug: coronavirus_page.slug }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /coronavirus/:slug/github_changes/update" do
    it "updates page content in publishing-api" do
      put :update, params: { slug: coronavirus_page.slug }

      assert_publishing_api_put_content(coronavirus_page.content_id)
      expect(response).to redirect_to(github_changes_coronavirus_page_path(coronavirus_page.slug))
    end
  end

  describe "POST /coronavirus/:slug/github_changes/publish" do
    it "publishes page content" do
      post :publish, params: { slug: coronavirus_page.slug }

      assert_publishing_api_publish(coronavirus_page.content_id)
      expect(response).to redirect_to(github_changes_coronavirus_page_path(coronavirus_page.slug))
    end
  end
end
