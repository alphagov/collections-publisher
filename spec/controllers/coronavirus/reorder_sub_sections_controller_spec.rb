require "rails_helper"

RSpec.describe Coronavirus::ReorderSubSectionsController do
  include CoronavirusFeatureSteps

  render_views
  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:page) { create :coronavirus_page }
  let(:slug) { page.slug }

  describe "GET /coronavirus/:page_slug/sub_sections/reorder" do
    it "renders page successfuly" do
      get :index, params: { page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /coronavirus/:page_slug/sub_sections/reorder" do
    before do
      stub_coronavirus_publishing_api
    end

    let(:sub_section_0) { create :coronavirus_sub_section, position: 1, page: page }
    let(:sub_section_1) { create :coronavirus_sub_section, position: 2, page: page }
    let(:section_params) { { sub_section_0.id => 2, sub_section_1.id => 1 } }

    subject { put :update, params: { page_slug: slug, section_order_save: section_params } }

    it "redirects to coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(slug))
    end

    it "reorders the sections" do
      subject
      expect(sub_section_0.reload.position).to eq 2
      expect(sub_section_1.reload.position).to eq 1
    end

    context "when a user manually enters an unconventional ordering approach" do
      let(:section_params) { { sub_section_0.id => 50, sub_section_1.id => 100 } }

      it "applies our expected incremental ordering" do
        subject
        expect(sub_section_0.reload.position).to eq 1
        expect(sub_section_1.reload.position).to eq 2
      end
    end

    context "when the submitted positions match the existing" do
      let(:section_params) { { sub_section_0.id => 1, sub_section_1.id => 2 } }

      it "keeps the section order" do
        subject
        expect(sub_section_0.reload.position).to eq 1
        expect(sub_section_1.reload.position).to eq 2
      end
    end

    context "on update failure" do
      before do
        stub_any_publishing_api_put_content.to_return(status: 500)
      end

      it "keeps the existing order if draft updater fails" do
        subject
        expect(sub_section_0.reload.position).to eq 1
        expect(sub_section_1.reload.position).to eq 2
      end

      it "redirects to coronavirus page on success" do
        expect(subject).to redirect_to(reorder_coronavirus_page_sub_sections_path(slug))
      end
    end
  end
end
