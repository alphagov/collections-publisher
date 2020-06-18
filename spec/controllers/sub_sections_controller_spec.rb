require "rails_helper"

RSpec.describe SubSectionsController, type: :controller do
  render_views

  let(:stub_user) { create :user, :unreleased_feature, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }
  let(:slug) { coronavirus_page.slug }
  let(:sub_section) { create :sub_section, coronavirus_page: coronavirus_page }
  let(:title) { Faker::Lorem.sentence }
  let(:content) { Faker::Lorem.sentence }
  let(:sub_section_params) do
    {
      title: title,
      content: content,
    }
  end

  describe "GET /coronavirus/:coronavirus_page_slug/sub_sections/new" do
    it "renders successfully" do
      get :new, params: { coronavirus_page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /coronavirus/:coronavirus_page_slug/sub_sections" do
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
  end

  describe "GET /coronavirus/:coronavirus_page_slug/sub_sections/:id/edit" do
    it "renders successfully" do
      get :edit, params: { id: sub_section, coronavirus_page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /coronavirus/:coronavirus_page_slug/sub_sections" do
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
