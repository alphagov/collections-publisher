require "rails_helper"

RSpec.describe SubSectionsController, type: :controller do
  render_views

  let(:stub_user) { create :user, :unreleased_feature, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }
  let(:slug) { coronavirus_page.slug }
  let(:sub_section) { create :sub_section, coronavirus_page: coronavirus_page }
  let(:title) { Faker::Lorem.sentence }
  let(:content) { "###{Faker::Lorem.sentence}" }
  let(:sub_section_params) do
    {
      title: title,
      content: content,
    }
  end
  let(:raw_content_url) { coronavirus_page.raw_content_url }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:raw_content) { File.read(fixture_path) }

  describe "GET /coronavirus/:coronavirus_page_slug/sub_sections/new" do
    it "renders successfully" do
      get :new, params: { coronavirus_page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /coronavirus/:coronavirus_page_slug/sub_sections" do
    before do
      stub_request(:get, raw_content_url)
        .to_return(body: raw_content)
      stub_coronavirus_publishing_api
    end
    subject do
      post :create, params: { coronavirus_page_slug: slug, sub_section: sub_section_params }
    end

    it "redirects to coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "create a new sub_section" do
      expect { subject }.to change { SubSection.count }.by(1)
    end

    it "adds attributes to new sub_section" do
      subject
      sub_section = SubSection.last
      expect(sub_section.title).to eq(title)
      expect(sub_section.content).to eq(content)
    end

    context "publishing api is returning a service error" do
      before do
        stub_any_publishing_api_put_content
          .to_return(status: 500)
      end
      it "successfully renders error on edit page" do
        expect(subject).to have_http_status(:success)
      end

      it "displays the expected error" do
        expect(subject.body).to include("Failed to update the draft content item - please try saving again")
      end
    end

    context "publishing api cannot process payload" do
      let(:error_message) { Faker::Lorem.sentence }
      before do
        stub_any_publishing_api_put_content
          .to_return(status: 422, body: error_message)
      end
      it "successfully renders error on edit page" do
        expect(subject).to have_http_status(:success)
      end

      it "displays the expected error" do
        expect(subject.body).to include(error_message)
      end
    end

    context "subsection content error" do
      let(:content) { "bad_content" }

      it "successfully renders error on edit page" do
        expect(subject).to have_http_status(:success)
      end

      it "displays the expected error" do
        expect(subject.body).to include("Unable to parse markdown:")
      end
    end
  end

  describe "GET /coronavirus/:coronavirus_page_slug/sub_sections/:id/edit" do
    it "renders successfully" do
      get :edit, params: { id: sub_section, coronavirus_page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /coronavirus/:coronavirus_page_slug/sub_sections" do
    before do
      stub_request(:get, raw_content_url)
        .to_return(body: raw_content)
      stub_coronavirus_publishing_api
    end
    let(:params) do
      {
        id: sub_section,
        coronavirus_page_slug: slug,
        sub_section: sub_section_params,
      }
    end

    subject { patch :update, params: params }

    it "redirects to coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "create a new sub_section" do
      sub_section
      expect { subject }.not_to(change { SubSection.count })
    end

    it "changes the attributes of the subsection" do
      subject
      sub_section.reload
      expect(sub_section.title).to eq(title)
      expect(sub_section.content).to eq(content)
    end
  end
end
