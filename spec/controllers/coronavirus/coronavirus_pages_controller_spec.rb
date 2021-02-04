require "rails_helper"

RSpec.describe Coronavirus::CoronavirusPagesController do
  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }
  let(:slug) { coronavirus_page.slug }
  let(:raw_content_url) { CoronavirusPages::Configuration.page(slug)[:raw_content_url] }
  let(:raw_content_url_regex) { Regexp.new(raw_content_url) }
  let(:all_content_urls) do
    CoronavirusPages::Configuration.all_pages.map do |config|
      config.second[:raw_content_url]
    end
  end
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:raw_content) { File.read(fixture_path) }
  let(:stub_all_content_urls) do
    all_content_urls.each do |url|
      stub_request(:get, Regexp.new(url))
        .to_return(status: 200, body: raw_content)
    end
  end

  describe "GET /coronavirus" do
    it "renders page successfully" do
      stub_all_content_urls
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /coronavirus/:slug/prepare" do
    subject { get :prepare, params: { slug: slug } }
    it "renders page successfuly" do
      stub_request(:get, raw_content_url_regex)
        .to_return(status: 200)
      expect(subject).to have_http_status(:success)
    end

    it "does not create a new coronavirus page" do
      coronavirus_page # ensure any creation during initialization doesn't get counted
      expect { subject }.not_to(change { Coronavirus::CoronavirusPage.count })
    end

    context "with unknown slug" do
      let(:slug) { :unknown }
      it "redirects to index" do
        expect(subject).to redirect_to(coronavirus_pages_path)
      end
    end

    context "with a new known coronavirus page" do
      let(:coronavirus_page) { build :coronavirus_page, :of_known_type }

      it "renders page successfuly" do
        stub_request(:get, raw_content_url_regex)
          .to_return(status: 200, body: raw_content)
        expect(subject).to have_http_status(:success)
      end

      it "creates a new coronavirus page" do
        stub_request(:get, raw_content_url_regex)
          .to_return(status: 200, body: raw_content)
        coronavirus_page # ensure any creation during initialization doesn't get counted
        expect { subject }.to (change { Coronavirus::CoronavirusPage.count }).by(1)
      end
    end
  end

  describe "GET /coronavirus/:slug" do
    it "renders page successfuly" do
      get :show, params: { slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end

    it "redirects to index with an unknown slug" do
      get :show, params: { slug: "unknown" }
      expect(response).to redirect_to(coronavirus_pages_path)
    end
  end

  describe "GET /coronavirus/:slug/discard" do
    let(:content_fixture_path) { Rails.root.join("spec/fixtures/coronavirus_page_sections.json") }
    let(:live_content_item) { JSON.parse(File.read(content_fixture_path)) }
    let(:live_sections) { live_content_item.dig("details", "sections") }
    let(:live_title) { live_sections.first["title"] }
    let(:slug) { "landing" }
    let(:coronavirus_page) do
      create :coronavirus_page,
             content_id: live_content_item["content_id"],
             base_path: live_content_item["base_path"],
             slug: slug
    end
    let(:subsection) { create :sub_section, coronavirus_page_id: coronavirus_page.id, title: "foo" }
    subject { get :discard, params: { slug: slug } }

    before do
      stub_publishing_api_has_item(live_content_item)
      stub_any_publishing_api_discard_draft
    end

    it "instructs publishing api to discard the draft content item" do
      subsection
      subject
      assert_publishing_api_discard_draft(coronavirus_page.content_id)
    end
  end
end
