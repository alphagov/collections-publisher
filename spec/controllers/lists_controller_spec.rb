require "rails_helper"

RSpec.describe ListsController do
  describe "GET show" do
    let(:list) { create(:list, tag: tag) }

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page) }

      it "assign the correct instance variables and renders the show template" do
        stub_user.update!(permissions: ["signin", "GDS Editor", "Redesigned lists"])

        get :show, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :show
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        get :show, params: { tag_id: tag.content_id, id: list.id }

        expect(response.status).to eq(403)
      end
    end

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic) }

      it "assign the correct instance vaiables and renders the show template" do
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        get :show, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :show
      end
    end
  end
end
