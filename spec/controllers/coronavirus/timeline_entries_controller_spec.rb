require "rails_helper"

RSpec.describe Coronavirus::TimelineEntriesController do
  include CoronavirusFeatureSteps

  render_views

  let(:stub_user) { create :user, name: "Name Surname" }
  let(:page) { create :coronavirus_page }

  describe "GET /coronavirus/:page_slug/timeline_entries/new" do
    it "can only be accessed by users with Coronavirus editor permissions" do
      stub_user.permissions << "Coronavirus editor"
      get :new, params: { page_slug: page.slug }

      expect(response).to have_http_status(:ok)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      get :new, params: { page_slug: page.slug }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /coronavirus/:page_slug/timeline_entries" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let(:heading) { Faker::Lorem.sentence }
    let(:content) { Faker::Lorem.sentence }
    let(:national_applicability) { %w[england wales] }
    let(:timeline_entry_params) do
      {
        heading: heading,
        content: content,
        national_applicability: national_applicability,
      }
    end

    before do
      stub_coronavirus_landing_page_content(page)
      stub_any_publishing_api_call
    end

    context "when a timeline entry is valid" do
      it "creates a timeline entry" do
        expect { post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params } }
          .to change { Coronavirus::TimelineEntry.where(heading: heading).count }.by(1)
      end

      it "redirects to coronavirus page" do
        post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params }
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end

    context "when the timeline entry is invalid" do
      let(:heading) { "" }

      it "doesn't create a timeline entry" do
        expect { post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params } }
          .not_to(change { Coronavirus::TimelineEntry.count })
      end

      it "returns an unprocessable entity response" do
        post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the errors" do
        post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params }
        expect(response.body).to include(CGI.escapeHTML("Heading can't be blank"))
      end
    end

    context "when there is a problem updating the Publishing API" do
      before { stub_publishing_api_isnt_available }

      it "doesn't create a timeline entry" do
        expect {
          post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params }
        }.not_to(change { Coronavirus::TimelineEntry.count })
      end

      it "returns a internal server error response" do
        post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params }
        expect(response).to have_http_status(:internal_server_error)
      end

      it "renders the errors" do
        post :create, params: { page_slug: page.slug, timeline_entry: timeline_entry_params }
        expect(response.body).to include("Failed to update the draft content item. Try saving again.")
      end
    end
  end

  describe "GET /coronavirus/:page_slug/timeline_entries/:id/edit" do
    let(:timeline_entry) { create(:coronavirus_timeline_entry, page: page) }

    it "can only be accessed by users with Coronavirus editor permissions" do
      stub_user.permissions << "Coronavirus editor"
      get :edit,
          params: {
            id: timeline_entry.id,
            page_slug: page.slug,
          }

      expect(response).to have_http_status(:ok)
    end

    it "cannot be accessed by users without Coronavirus editor permissions" do
      get :edit,
          params: {
            id: timeline_entry.id,
            page_slug: page.slug,
          }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /coronavirus/:page_slug/timeline_entries/:id" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let!(:timeline_entry) { create(:coronavirus_timeline_entry, page: page) }
    let(:heading) { "Updated heading" }
    let(:national_applicability) { %w[england wales] }

    let(:updated_timeline_entry_params) do
      {
        heading: heading,
        content: "##Updated content",
        national_applicability: national_applicability,
      }
    end

    let(:params) do
      {
        id: timeline_entry.id,
        page_slug: page.slug,
        timeline_entry: updated_timeline_entry_params,
      }
    end

    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    context "when a timeline entry is valid" do
      it "updates a timeline entry" do
        expect { patch :update, params: params }
          .to change { timeline_entry.reload.heading }.to(heading)
      end

      it "redirects to coronavirus page" do
        patch :update, params: params
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end

    context "when the timeline entry is invalid" do
      let(:heading) { "" }

      it "doesn't update a timeline entry" do
        expect { patch :update, params: params }
          .not_to(change { timeline_entry.reload.heading })
      end

      it "returns an unprocessable entity response" do
        patch :update, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the errors" do
        patch :update, params: params
        expect(response.body).to include(CGI.escapeHTML("Heading can't be blank"))
      end
    end

    context "when there is a problem updating the Publishing API" do
      before { stub_publishing_api_isnt_available }

      it "doesn't update a timeline entry" do
        expect { patch :update, params: params }
          .not_to(change { timeline_entry.reload.heading })
      end

      it "returns a internal server error response" do
        patch :update, params: params
        expect(response).to have_http_status(:internal_server_error)
      end

      it "renders the errors" do
        patch :update, params: params
        expect(response.body).to include("Failed to update the draft content item. Try saving again.")
      end
    end
  end

  describe "DELETE /coronavirus/:page_slug/timeline_entries/:id" do
    let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
    let!(:timeline_entry) { create(:coronavirus_timeline_entry, page: page, heading: "Skywalker") }

    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    it "redirects to the coronavirus page" do
      delete :destroy,
             params: {
               id: timeline_entry.id,
               page_slug: page.slug,
             }

      expect(response).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "deletes the timeline entry" do
      delete :destroy,
             params: {
               id: timeline_entry.id,
               page_slug: page.slug,
             }

      expect(page.reload.timeline_entries.count).to eq(0)
    end

    it "doesn't delete the timeline_entry if draft_updater fails" do
      stub_publishing_api_isnt_available
      create(:coronavirus_timeline_entry, page: page, heading: "Amidala")

      params = {
        id: timeline_entry.id,
        page_slug: page.slug,
      }

      expect { delete :destroy, params: params }
        .to_not(change { page.reload.timeline_entries.to_a })
    end
  end
end
