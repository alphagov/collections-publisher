require "rails_helper"

RSpec.describe Coronavirus::PagesController do
  include CoronavirusFeatureSteps
  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let!(:page) { create :coronavirus_page }
  let(:slug) { page.slug }

  describe "GET /coronavirus" do
    it "renders page successfully" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /coronavirus/:slug" do
    it "renders page successfuly" do
      get :show, params: { slug: page.slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /coronavirus/:slug/discard" do
    let(:content_fixture_path) { Rails.root.join("spec/fixtures/coronavirus_page_sections.json") }
    let(:live_content_item) { JSON.parse(File.read(content_fixture_path)) }
    let(:live_sections) { live_content_item.dig("details", "sections") }
    let(:live_title) { live_sections.first["title"] }
    let(:slug) { "landing" }
    let!(:page) do
      create :coronavirus_page,
             content_id: live_content_item["content_id"],
             base_path: live_content_item["base_path"],
             slug:
    end
    let!(:subsection) { create :coronavirus_sub_section, page:, title: "foo" }
    subject { get :discard, params: { slug: } }

    before do
      stub_publishing_api_has_item(live_content_item)
      stub_any_publishing_api_discard_draft
    end

    it "instructs publishing api to discard the draft content item" do
      subject
      assert_publishing_api_discard_draft(page.content_id)
    end
  end

  describe "GET /coronavirus/:slug/edit-header" do
    it "renders successfully" do
      get :edit_header, params: { page_slug: page.slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /coronavirus/:slug/edit-header" do
    let!(:page) do
      create :coronavirus_page,
             header_title: "title",
             header_body: "body",
             header_link_url: "https://www.hello.com",
             header_link_pre_wrap_text: "Pre wrap text",
             header_link_post_wrap_text: "Post wrap text"
    end

    let(:landing_page_params) do
      {
        header_title: "title updated",
        header_body: "body",
        header_link_url: "https://www.hello.com",
        header_link_pre_wrap_text: "Pre wrap text",
        header_link_post_wrap_text: "Post wrap text",
      }
    end

    let(:landing_page_with_invalid_param) do
      {
        header_title: "title updated",
        header_body: "body updated",
        header_link_url: "com",
        header_link_pre_wrap_text: "Pre wrap text",
        header_link_post_wrap_text: "Post wrap text",
      }
    end

    before do
      stub_coronavirus_publishing_api
    end

    context "when header is valid" do
      it "updates header data" do
        expect { patch :update_header, params: { page_slug: page.slug, landing_page: landing_page_params } }.to change { page.reload.header_title }.to("title updated")
      end

      it "redirects to coronavirus page" do
        patch :update_header, params: { page_slug: page.slug, landing_page: landing_page_params }
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end

    context "when header is invalid" do
      it "does not update header data" do
        patch :update_header, params: { page_slug: page.slug, landing_page: landing_page_with_invalid_param }
        expect(page.header_body).to eq("body")
      end

      it "returns an unprocessable entity response" do
        patch :update_header, params: { page_slug: page.slug, landing_page: landing_page_with_invalid_param }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders error" do
        patch :update_header, params: { page_slug: page.slug, landing_page: landing_page_with_invalid_param }

        expect(response.body).to include(CGI.escapeHTML("Header link url needs to be a https:// URL or a path prefixed with /"))
      end
    end
  end
end
