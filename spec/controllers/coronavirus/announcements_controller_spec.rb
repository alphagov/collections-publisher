require "rails_helper"

RSpec.describe Coronavirus::AnnouncementsController do
  include CoronavirusFeatureSteps

  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:page) { create :coronavirus_page, :landing }
  let!(:announcement) { create :coronavirus_announcement, page: page }
  let(:title) { Faker::Lorem.sentence }
  let(:path) { "/government/foo/vader/baby/yoda" }
  let(:published_at) { { "day" => "12", "month" => "12", "year" => "1980" } }

  describe "GET /coronavirus/:page_slug/announcements/new" do
    it "does not render successfully if the user does not have Coronavirus editor permissions" do
      stub_user.permissions = %w[signin]
      get :new, params: { page_slug: page.slug }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /coronavirus/:page_slug/announcements" do
    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    let(:announcement_params) do
      {
        title: title,
        path: path,
        published_at: published_at,
      }
    end

    context "when an announcement is valid" do
      it "creates an announcement" do
        expect { post :create, params: { page_slug: page.slug, announcement: announcement_params } }
          .to change { Coronavirus::Announcement.where(title: title).count }.by(1)
      end

      it "redirects to coronavirus page" do
        post :create, params: { page_slug: page.slug, announcement: announcement_params }
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end

    context "when the announcement is invalid" do
      let(:title) { "" }

      it "doesn't create an announcement" do
        expect { post :create, params: { page_slug: page.slug, announcement: announcement_params } }
          .not_to(change { Coronavirus::Announcement.count })
      end

      it "returns an unprocessable entity response" do
        post :create, params: { page_slug: page.slug, announcement: announcement_params }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the errors" do
        post :create, params: { page_slug: page.slug, announcement: announcement_params }
        expect(response.body).to include(CGI.escapeHTML("Title can't be blank"))
      end
    end

    context "when there is a problem updating the Publishing API" do
      before { stub_publishing_api_isnt_available }

      it "doesn't create an announcement" do
        expect { post :create, params: { page_slug: page.slug, announcement: announcement_params } }
          .not_to(change { Coronavirus::Announcement.count })
      end

      it "returns a internal server error response" do
        post :create, params: { page_slug: page.slug, announcement: announcement_params }
        expect(response).to have_http_status(:internal_server_error)
      end

      it "renders the errors" do
        post :create, params: { page_slug: page.slug, announcement: announcement_params }
        expect(response.body).to include("Failed to update the draft content item. Try saving again.")
      end
    end
  end

  describe "DELETE /coronavirus/:page_slug/announcements/:id" do
    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    let(:announcement_params) do
      {
        id: announcement,
        page_slug: page.slug,
      }
    end

    it "redirects to the coronavirus page" do
      delete :destroy, params: announcement_params
      expect(response).to redirect_to(coronavirus_page_path(page.slug))
    end

    it "deletes the announcement" do
      expect { delete :destroy, params: announcement_params }
        .to change { Coronavirus::Announcement.count }.by(-1)
    end

    it "doesn't delete the announcement if draft_updater fails" do
      stub_publishing_api_isnt_available

      expect { delete :destroy, params: announcement_params }
        .not_to(change { Coronavirus::Announcement.count })
    end
  end

  describe "GET /coronavirus/:page_slug/announcements/:id/edit" do
    it "renders successfully" do
      get :edit, params: { id: announcement, page_slug: page.slug }
      expect(response).to have_http_status(:success)
    end

    it "does not render successfully if the user does not have Coronavirus editor permissions" do
      stub_user.permissions = %w[signin]
      get :new, params: { page_slug: page.slug }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /coronavirus/:page_slug/announcement" do
    before do
      stub_coronavirus_landing_page_content(page)
      stub_coronavirus_publishing_api
    end

    let(:updated_announcement_params) do
      {
        title: title,
        path: "/updated/path",
        published_at: published_at,
      }
    end

    let(:params) do
      {
        id: announcement.id,
        page_slug: page.slug,
        announcement: updated_announcement_params,
      }
    end

    context "when an announcement is valid" do
      it "updates an announcement" do
        expect { patch :update, params: params }
          .to change { announcement.reload.title }.to(title)
      end

      it "redirects to coronavirus page" do
        patch :update, params: params
        expect(response).to redirect_to(coronavirus_page_path(page.slug))
      end
    end

    context "when the announcement is invalid" do
      let(:title) { "" }

      it "doesn't update an announcement" do
        expect { patch :update, params: params }
          .not_to(change { announcement.reload.title })
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

    context "when there is a problem updating the Publishing API" do
      before { stub_publishing_api_isnt_available }

      it "doesn't update an announcement" do
        expect { patch :update, params: params }
          .not_to(change { announcement.reload.title })
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
end
