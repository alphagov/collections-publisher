require "rails_helper"

RSpec.describe ListItemsController, type: :controller do
  let(:tag) { create(:tag) }
  let(:list) { create(:list, tag:) }
  let(:title) { "List item title" }
  let(:path) { "/government/foo/vader/baby/yoda" }

  describe "destroy" do
    let!(:list_item) { create(:list_item, list:) }
    let(:tag) { create(:mainstream_browse_page, :published) }

    before do
      stub_any_publishing_api_call
    end

    it "destroys a list item and makes the correct calls to the Publishing API" do
      stub_user.update!(permissions: ["signin", "GDS Editor"])

      patch :destroy, params: {
        tag_id: tag.content_id,
        list_id: list.id,
        id: list_item.id,
      }

      expect { ListItem.find(list_item.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response.status).to eq(302)
      expect(response).to redirect_to(tag_list_path(tag, list))
      expect(flash.notice).to eq "#{list_item.title} removed from list"
      assert_publishing_api_put_content(
        tag.content_id,
        request_json_includes(
          "details" => {
            "groups" => [
              {
                "name" => list.name,
                "content_ids" => [],
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

      patch :destroy, params: {
        tag_id: tag.content_id,
        list_id: list.id,
        id: list_item.id,
      }

      expect(response.status).to eq(403)
    end
  end

  describe "GET confirm_destroy" do
    let(:list) { create(:list, tag:) }
    let!(:list_item) { create(:list_item, list:) }

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page) }

      it "assigns the correct instance variables and renders the confirm_destroy template" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        get :confirm_destroy, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(assigns(:list_item).id).to eq list_item.id
        expect(response.status).to eq(200)
        expect(response).to render_template :confirm_destroy
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: %w[signin])

        get :confirm_destroy, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(response.status).to eq(403)
      end
    end
  end

  describe "GET move" do
    let(:list) { create(:list, tag:) }
    let!(:list_item) { create(:list_item, list:) }

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page) }

      it "assign the correct instance variables and renders the move template" do
        stub_user.update!(permissions: ["signin", "GDS Editor", "Redesigned lists"])

        get :move, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(assigns(:list_item).id).to eq list_item.id
        expect(response.status).to eq(200)
        expect(response).to render_template :move
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        get :move, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(response.status).to eq(403)
      end
    end
  end

  describe "PATCH update_move" do
    let(:list1) { create(:list, tag:) }
    let(:list2) { create(:list, tag:) }
    let!(:list_item1) { create(:list_item, list: list1, index: 1) }
    let!(:list_item2) { create(:list_item, list: list1, index: 2) }
    let(:tagged_documents) do
      [
        TaggedDocuments::Document.new(list_item1.title, "/some-path-1", list_item1.content_id),
        TaggedDocuments::Document.new(list_item2.title, "/some-path-2", list_item2.content_id),
        TaggedDocuments::Document.new("New list", "/new-list", "789"),
      ]
    end

    before do
      stub_any_publishing_api_call
      allow_any_instance_of(TaggedDocuments).to receive(:documents).and_return(tagged_documents)
    end

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page, :published) }

      it "updates the list item to belong to list_id passed in and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        patch :update_move, params: {
          tag_id: tag.content_id,
          list_id: list1.id,
          id: list_item1.id,
          list_item: { new_list_id: list2.id },
        }

        expect(list1.reload.list_items.count).to eq 1
        expect(list2.reload.list_items.count).to eq 1
        expect(response.status).to eq(302)
        expect(response).to redirect_to(tag_list_path(tag, list1))
        expect(flash.notice).to eq "#{list_item1.title} moved to #{list2.name} successfully"
        assert_publishing_api_put_content(
          tag.content_id,
          request_json_includes(
            "details" => {
              "groups" => [
                {
                  "name" => list1.name,
                  "content_ids" => [
                    list_item2.content_id,
                  ],
                },
                {
                  "name" => list2.name,
                  "content_ids" => [
                    list_item1.content_id,
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

        patch :update_move, params: {
          tag_id: tag.content_id,
          list_id: list1.id,
          id: list_item1.id,
          list_item: { new_list_id: list2.id },
        }

        expect(response.status).to eq(403)
      end

      it "adds and error and renders the move view if a new_list_id is not passed in" do
        stub_user.update!(permissions: ["signin", "GDS Editor"])

        patch :update_move, params: {
          tag_id: tag.content_id,
          list_id: list1.id,
          id: list_item1.id,
        }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list1.id
        expect(assigns(:list_item).id).to eq list_item1.id
        expect(assigns(:list_item).errors.first.message).to eq "Choose a list"
        expect(response.status).to eq(200)
        expect(response).to render_template :move
      end
    end
  end
end
