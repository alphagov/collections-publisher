require "rails_helper"

RSpec.describe Coronavirus::ReorderSubSectionsController do
  include CoronavirusFeatureSteps

  render_views
  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }
  let(:slug) { coronavirus_page.slug }

  describe "GET /coronavirus/:coronavirus_page_slug/sub_sections/reorder" do
    it "renders page successfuly" do
      get :index, params: { coronavirus_page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /coronavirus/:coronavirus_page_slug/sub_sections/reorder" do
    before do
      stub_coronavirus_landing_page_content(coronavirus_page)
      stub_coronavirus_publishing_api
    end
    let(:sub_section_0) { create :sub_section, position: 0, coronavirus_page: coronavirus_page }
    let(:sub_section_1) { create :sub_section, position: 1, coronavirus_page: coronavirus_page }

    let(:sub_section_0_params) { { id: sub_section_0.id, position: 1 } }
    let(:sub_section_1_params) { { id: sub_section_1.id, position: 0 } }
    let(:section_params) { [sub_section_0_params, sub_section_1_params].to_json }

    subject { put :update, params: { coronavirus_page_slug: slug, section_order_save: section_params } }

    it "redirects to coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(slug))
    end

    it "reorders the sections" do
      subject
      expect(sub_section_0.reload.position).to eq 1
      expect(sub_section_1.reload.position).to eq 0
    end

    context "when the submitted positions match the existing" do
      let(:sub_section_0_params) { { id: sub_section_0.id, position: 0 } }
      let(:sub_section_1_params) { { id: sub_section_1.id, position: 1 } }

      it "keeps the section order" do
        subject
        expect(sub_section_0.reload.position).to eq 0
        expect(sub_section_1.reload.position).to eq 1
      end
    end

    context "on update failure" do
      before do
        stub_any_publishing_api_put_content.to_return(status: 500)
      end

      it "keeps the existing order if draft updater fails" do
        subject
        expect(sub_section_0.reload.position).to eq 0
        expect(sub_section_1.reload.position).to eq 1
      end

      it "redirects to coronavirus page on success" do
        expect(subject).to redirect_to(reorder_coronavirus_page_sub_sections_path(slug))
      end
    end
  end
end
