require "rails_helper"

RSpec.describe Coronavirus::SubSectionsController do
  include CoronavirusFeatureSteps

  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:page) { create :coronavirus_page }
  let!(:sub_section) { create :coronavirus_sub_section, page: }
  let(:title) { Faker::Lorem.sentence }
  let(:content) { "###{Faker::Lorem.sentence}" }
  let(:sub_section_params) do
    {
      title:,
      content:,
    }
  end

  describe "GET /coronavirus/:page_slug/sub_sections/new" do
    it "renders successfully" do
      get :new, params: { page_slug: page.slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /coronavirus/:page_slug/sub_sections" do
    before do
      stub_coronavirus_publishing_api
    end

    let(:params) do
      {
        page_slug: page.slug,
        sub_section: sub_section_params,
      }
    end

    context "when a subsection is valid" do
      it "creates a subsection" do
        expect { post :create, params: }
          .to change { Coronavirus::SubSection.where(title:).count }.by(1)
      end

      it "redirects to coronavirus page" do
        post :create, params: params
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end

    context "when the subsection is invalid" do
      context "when the title is invalid" do
        let(:title) { "" }

        it "doesn't create a subsection" do
          expect { post :create, params: }
            .not_to(change { Coronavirus::SubSection.count })
        end

        it "returns an unprocessable entity response" do
          post :create, params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders the errors" do
          post :create, params: params
          expect(response.body).to include(CGI.escapeHTML("Title can't be blank"))
        end
      end

      context "when the content is invalid" do
        let(:content) { "###Title \n [label](/brexit" }

        it "doesn't create a subsection" do
          expect { post :create, params: }
            .not_to(change { Coronavirus::SubSection.count })
        end

        it "renders the errors" do
          post :create, params: params
          expect(response.body).to include(CGI.escapeHTML("unable to parse markdown"))
        end
      end
    end

    context "when there is a problem updating the Publishing API" do
      before { stub_publishing_api_isnt_available }

      it "doesn't create a subsection" do
        expect { post :create, params: }
          .not_to(change { Coronavirus::SubSection.count })
      end

      it "returns a internal server error response" do
        post :create, params: params
        expect(response).to have_http_status(:internal_server_error)
      end

      it "renders the errors" do
        post :create, params: params
        expect(response.body).to include("Failed to update the draft content item. Try saving again.")
      end
    end
  end

  describe "GET /coronavirus/:page_slug/sub_sections/:id/edit" do
    it "renders successfully" do
      get :edit, params: { id: sub_section, page_slug: page.slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /coronavirus/:page_slug/sub_sections" do
    before do
      stub_coronavirus_publishing_api
    end

    let(:params) do
      {
        id: sub_section,
        page_slug: page.slug,
        sub_section: sub_section_params,
      }
    end

    context "when a subsection is valid" do
      it "updates a subsection" do
        expect { patch :update, params: }
          .to change { sub_section.reload.title }.to(title)
      end

      it "redirects to coronavirus page" do
        patch :update, params: params
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end

    context "when the subsection is invalid" do
      context "when the title is invalid" do
        let(:title) { "" }

        it "doesn't update a subsection" do
          expect { patch :update, params: }
            .not_to(change { sub_section.reload.title })
        end

        it "returns an unprocessable entity response" do
          patch :update, params: params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders the errors" do
          patch :update, params: params
          expect(response.body).to include(CGI.escapeHTML("Title can't be blank"))
        end
      end

      context "when the content is invalid" do
        let(:content) { "###Title \n [label](/brexit" }

        it "doesn't update the structured content" do
          expect { patch :update, params: }
            .not_to(change { sub_section.reload.structured_content })
        end

        it "renders the errors" do
          patch :update, params: params
          expect(response.body).to include(CGI.escapeHTML("unable to parse markdown"))
        end
      end
    end

    context "when there is a problem updating the Publishing API" do
      before { stub_publishing_api_isnt_available }

      it "doesn't update a subsection" do
        expect { patch :update, params: }
          .not_to(change { sub_section.reload.title })
      end

      it "returns an internal server error response" do
        patch :update, params: params
        expect(response).to have_http_status(:internal_server_error)
      end

      it "renders the errors" do
        patch :update, params: params
        expect(response.body).to include("Failed to update the draft content item. Try saving again.")
      end
    end
  end

  describe "DELETE /coronavirus/:page_slug/sub_sections/:id" do
    before do
      stub_coronavirus_publishing_api
    end
    let(:params) do
      {
        id: sub_section,
        page_slug: page.slug,
      }
    end
    subject { delete :destroy, params: }

    it "redirects to the coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "deletes the subsection" do
      expect { subject }.to change { Coronavirus::SubSection.count }.by(-1)
    end

    it "doesn't delete the subsection if draft_updater fails" do
      stub_publishing_api_isnt_available

      expect { subject }.to_not(change { page.reload.sub_sections.to_a })
    end
  end
end
