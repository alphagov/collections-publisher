require "rails_helper"

RSpec.describe ListsController do
  include PublishingApiHelpers

  describe "GET show" do
    let(:list) { create(:list, tag: tag) }

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page) }

      it "assign the correct instance variables and renders the show template" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        get :show, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :show
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: %w[signin])

        get :show, params: { tag_id: tag.content_id, id: list.id }

        expect(response.status).to eq(403)
      end
    end

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic) }

      it "assign the correct instance vaiables and renders the show template" do
        stub_user.update!(permissions: %w[signin])

        get :show, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :show
      end
    end
  end

  describe "GET edit_list_items" do
    let(:list) { create(:list, tag: tag) }

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page) }

      it "assign the correct instance variables and renders the edit_list_items template" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        get :edit_list_items, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :edit_list_items
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: %w[signin])

        get :edit_list_items, params: { tag_id: tag.content_id, id: list.id }

        expect(response.status).to eq(403)
      end
    end

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic) }

      it "assign the correct instance vaiables and renders the edit_list_items template" do
        stub_user.update!(permissions: %w[signin])

        get :edit_list_items, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :edit_list_items
      end
    end
  end

  describe "PATCH update_list_items" do
    let(:list) { create(:list, tag: tag) }
    let!(:list_item1) { create(:list_item, list: list, index: 1) }
    let!(:list_item2) { create(:list_item, list: list, index: 2) }
    let(:tagged_documents) do
      [
        TaggedDocuments::Document.new(list_item1.title, list_item1.base_path, "123"),
        TaggedDocuments::Document.new(list_item2.title, list_item2.base_path, "456"),
        TaggedDocuments::Document.new("New list", "/new-list", "789"),
        TaggedDocuments::Document.new("Newer list", "/newer-list", "012"),
      ]
    end

    before do
      stub_any_publishing_api_call
      allow_any_instance_of(TaggedDocuments).to receive(:documents).and_return(tagged_documents)
    end

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page, :published) }

      it "creates a new list item and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        patch :update_list_items, params: {
          tag_id: tag.content_id,
          id: list.id,
          list: { list_items: ["/new-list", "/newer-list"] },
        }

        new_list_item1, new_list_item2 = list.list_items.last(2)

        expect(list.list_items.count).to eq 4
        expect(new_list_item1.title).to eq "New list"
        expect(new_list_item1.base_path).to eq "/new-list"
        expect(new_list_item1.index).to eq 3
        expect(new_list_item2.title).to eq "Newer list"
        expect(new_list_item2.base_path).to eq "/newer-list"
        expect(new_list_item2.index).to eq 4
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tag_list_path(tag, list))
        expect(flash.notice).to eq "2 links successfully added to the list"
        assert_publishing_api_put_content(
          tag.content_id,
          request_json_includes(
            "details" => {
              "groups" => [
                {
                  "name" => list.name,
                  "contents" => [
                    list_item1.base_path,
                    list_item2.base_path,
                    "/new-list",
                    "/newer-list",
                  ],
                },
              ],
              "internal_name" => tag.title,
              "second_level_ordering" => "alphabetical",
              "ordered_second_level_browse_pages" => [],
            },
          ),
        )
        assert_publishing_api_publish(tag.content_id)
        assert_publishing_api_patch_links(tag.content_id)
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: %w[signin])

        patch :update_list_items, params: { tag_id: tag.content_id, id: list.id, list: { list_items: ["/new-list"] } }

        expect(response.status).to eq(403)
      end

      it "adds an error to the list and rerenders then page when no list items are passed into the params" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        patch :update_list_items, params: { tag_id: tag.content_id, id: list.id, list: { list_items: [] } }

        expect(assigns(:list).errors.first.message).to eq "Select a link to add to the list"
        expect(response).to render_template :edit_list_items
      end
    end

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic, :published) }

      it "creates a new list item and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: %w[signin])

        patch :update_list_items, params: { tag_id: tag.content_id, id: list.id, list: { list_items: ["/new-list"] } }

        new_list_item = list.reload.list_items.last

        expect(list.list_items.count).to eq 3
        expect(new_list_item.title).to eq "New list"
        expect(new_list_item.base_path).to eq "/new-list"
        expect(new_list_item.index).to eq 3
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tag_list_path(tag, list))
        expect(flash.notice).to eq "1 link successfully added to the list"
        assert_publishing_api_put_content(
          tag.content_id,
          request_json_includes(
            "details" => {
              "groups" => [
                {
                  "name" => list.name,
                  "contents" => [
                    list_item1.base_path,
                    list_item2.base_path,
                    "/new-list",
                  ],
                },
              ],
              "internal_name" => tag.title,
            },
          ),
        )
        assert_publishing_api_publish(tag.content_id)
        assert_publishing_api_patch_links(tag.content_id)
      end
    end
  end

  describe "GET manage_list_item_ordering" do
    let(:list) { create(:list, tag: tag) }

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page) }

      it "assign the correct instance variables and renders the manage_list_item_ordering template" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        get :manage_list_item_ordering, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :manage_list_item_ordering
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: %w[signin])

        get :manage_list_item_ordering, params: { tag_id: tag.content_id, id: list.id }

        expect(response.status).to eq(403)
      end
    end

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic) }

      it "assign the correct instance vaiables and renders the manage_list_item_ordering template" do
        stub_user.update!(permissions: %w[signin])

        get :manage_list_item_ordering, params: { tag_id: tag.content_id, id: list.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(response.status).to eq(200)
        expect(response).to render_template :manage_list_item_ordering
      end
    end
  end

  describe "PATCH update_list_item_ordering" do
    let(:list) { create(:list, tag: tag) }
    let!(:list_item1) { create(:list_item, list: list, index: 1) }
    let!(:list_item2) { create(:list_item, list: list, index: 2) }
    let(:tagged_documents) do
      [
        TaggedDocuments::Document.new(list_item1.title, list_item1.base_path, "123"),
        TaggedDocuments::Document.new(list_item2.title, list_item2.base_path, "456"),
        TaggedDocuments::Document.new("New list", "/new-list", "789"),
      ]
    end

    before do
      stub_any_publishing_api_call
      allow_any_instance_of(TaggedDocuments).to receive(:documents).and_return(tagged_documents)
    end

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page, :published) }

      it "updates the list link ordering and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        patch :update_list_item_ordering, params: {
          tag_id: tag.content_id,
          id: list.id,
          ordering: { list_item2.id => "1", list_item1.id => "2" },
        }

        expect(list_item2.reload.index).to eq 1
        expect(list_item1.reload.index).to eq 2
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tag_list_path(tag, list))
        expect(flash.notice).to eq "List links reordered successfully"
        assert_publishing_api_put_content(
          tag.content_id,
          request_json_includes(
            "details" => {
              "groups" => [
                {
                  "name" => list.name,
                  "contents" => [
                    list_item2.base_path,
                    list_item1.base_path,
                  ],
                },
              ],
              "internal_name" => tag.title,
              "second_level_ordering" => "alphabetical",
              "ordered_second_level_browse_pages" => [],
            },
          ),
        )
        assert_publishing_api_publish(tag.content_id)
        assert_publishing_api_patch_links(tag.content_id)
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: %w[signin])

        patch :update_list_item_ordering, params: {
          tag_id: tag.content_id,
          id: list.id,
          ordering: { list_item2.id => "1", list_item1.id => "2" },
        }

        expect(response.status).to eq(403)
      end
    end

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic, :published) }

      it "updates the list link ordering and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: %w[signin])

        patch :update_list_item_ordering, params: {
          tag_id: tag.content_id,
          id: list.id,
          ordering: { list_item2.id => "1", list_item1.id => "2" },
        }

        expect(list_item2.reload.index).to eq 1
        expect(list_item1.reload.index).to eq 2
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tag_list_path(tag, list))
        expect(flash.notice).to eq "List links reordered successfully"
        assert_publishing_api_put_content(
          tag.content_id,
          request_json_includes(
            "details" => {
              "groups" => [
                {
                  "name" => list.name,
                  "contents" => [
                    list_item2.base_path,
                    list_item1.base_path,
                  ],
                },
              ],
              "internal_name" => tag.title,
            },
          ),
        )
        assert_publishing_api_publish(tag.content_id)
        assert_publishing_api_patch_links(tag.content_id)
      end
    end
  end
end
