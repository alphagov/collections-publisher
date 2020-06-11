require "rails_helper"

RSpec.describe CoronavirusPagesController, type: :controller do
  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }

  describe "GET /coronavirus" do
    it "renders page successfully" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /coronavirus/:slug/prepare" do
    let(:slug) { coronavirus_page.slug }
    subject { get :prepare, params: { slug: slug } }

    it "renders page successfuly" do
      expect(subject).to have_http_status(:success)
    end

    it "does not create a new coronavirus page" do
      coronavirus_page # ensure any creation during initialization doesn't get counted
      expect { subject }.not_to(change { CoronavirusPage.count })
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
        expect(subject).to have_http_status(:success)
      end

      it "creates a new coronavirus page" do
        coronavirus_page # ensure any creation during initialization doesn't get counted
        expect { subject }.to (change { CoronavirusPage.count }).by(1)
      end
    end
  end

  describe "GET /coronavirus/:slug" do
    it "renders page successfuly" do
      get :show, params: { slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end

    it "redirects to index with an unknown slug" do
      get :show, params: { slug: :unknown }
      expect(response).to redirect_to(coronavirus_pages_path)
    end
  end
end
