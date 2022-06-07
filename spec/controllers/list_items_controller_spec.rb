require "rails_helper"

RSpec.describe ListItemsController, type: :controller do
  let(:tag) { create(:tag) }
  let(:list) { create(:list, tag: tag) }
  let(:title) { "List item title" }
  let(:path) { "/government/foo/vader/baby/yoda" }

  describe "create" do
    subject! do
      post :create, params: {
        tag_id: tag.content_id,
        list_id: list.id,
        list_item: { title: title, base_path: path, index: index },
        format: format,
      }
    end

    context "HTML format" do
      let(:format) { :html }

      context "with valid parameters" do
        let(:index) { 3 }

        it "creates the list item" do
          list_item = list.list_items.last
          expect(list_item.title).to eq(title)
          expect(list_item.base_path).to eq(path)
          expect(list_item.index).to eq(index)
        end

        it "redirects to the tag lists path" do
          expect(subject).to redirect_to(tag_lists_path(tag))
        end

        it "indicates a success state to the user" do
          expect(flash.key?(:notice)).to be(true)
        end
      end

      context "with invalid parameters" do
        let(:index) { -1 }

        it "does not create the list item" do
          expect(list.list_items.count).to eq(0)
        end

        it "redirects to the tag lists path" do
          expect(subject).to redirect_to(tag_lists_path(tag))
        end

        it "indicates a fail state to the user" do
          expect(flash.key?(:alert)).to be(true)
        end
      end
    end

    context "JS format" do
      let(:format) { :js }

      context "with valid parameters" do
        let(:index) { 3 }

        it "creates the list item" do
          list_item = list.list_items.last
          expect(list_item.title).to eq(title)
          expect(list_item.base_path).to eq(path)
          expect(list_item.index).to eq(index)
        end

        it "returns a success status code" do
          expect(response).to have_http_status(:ok)
        end

        it "returns JSON containing the update URL" do
          json = JSON.parse(response.body)
          expect(json["errors"]).to eq([])
          expect(json["updateURL"]).to eq(tag_list_list_item_path(tag, list, list.list_items.last))
        end
      end

      context "with invalid parameters" do
        let(:index) { -1 }

        it "does not create the list item" do
          expect(list.list_items.count).to eq(0)
        end

        it "returns an error status code" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns JSON describing the errors" do
          json = JSON.parse(response.body)
          expect(json["errors"]).to eq({ "index" => ["must be greater than or equal to 0"] })
        end
      end
    end
  end

  describe "update" do
    let(:list_item) { create(:list_item, index: 7) }

    def patch_list_item
      patch :update, params: {
        tag_id: tag.content_id,
        list_id: list.id,
        format: :js,
        id: list_item.id,
        new_list_id: list.id,
        index: index,
      }
    end

    context "with valid parameters" do
      let(:index) { 3 }

      it "updates the list item" do
        patch_list_item
        expect(list_item.reload.index).to eq(index)
        expect(response).to have_http_status(:ok)
      end

      it "marks the tag as dirty" do
        expect(tag.reload.dirty).to be(false)
        patch_list_item
        expect(tag.reload.dirty).to be(true)
      end
    end

    context "with invalid parameters" do
      let(:index) { -1 }

      it "does not update the list item" do
        patch_list_item
        expect(list_item.reload.index).to eq(7)
      end

      it "returns an error status code" do
        patch_list_item
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns JSON describing the errors" do
        patch_list_item
        json = JSON.parse(response.body)
        expect(json["errors"]).to eq({ "index" => ["must be greater than or equal to 0"] })
      end
    end
  end

  describe "destroy" do
    let!(:list_item) { create(:list_item, list: list) }

    context "HTML format" do
      let(:format) { :html }

      context "with a valid list item ID" do
        before { destroy_list_item }

        it "destroys the list item" do
          expect { ListItem.find(list_item.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "marks the tag as dirty" do
          expect(tag.reload.dirty).to eq(true)
        end

        it "indicates a success state to the user" do
          expect(flash.key?(:notice)).to be(true)
        end

        it "redirects to tag lists path" do
          expect(subject).to redirect_to(tag_lists_path(tag))
        end
      end

      context "with a list item that can't be deleted" do
        before { stub_tag_class }

        it "redirects to the tag lists path" do
          expect(destroy_list_item).to redirect_to(tag_lists_path(tag))
        end

        it "does not mark the tag as dirty" do
          expect(tag).to_not receive(:mark_as_dirty!)
          destroy_list_item
        end

        it "indicates a fail state to the user" do
          destroy_list_item
          expect(flash.key?(:alert)).to be(true)
        end
      end
    end

    context "JS format" do
      let(:format) { :js }

      context "with a valid list item ID" do
        before { destroy_list_item }

        it "destroys the list item" do
          expect { ListItem.find(list_item.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "marks the tag as dirty" do
          expect(tag.reload.dirty).to eq(true)
        end

        it "returns a success status code" do
          expect(response).to have_http_status(:ok)
        end

        it "returns JSON confirming no errors" do
          json = JSON.parse(response.body)
          expect(json["errors"]).to eq([])
        end
      end

      context "with a list item that can't be deleted" do
        before { stub_tag_class }

        it "does not mark the tag as dirty" do
          expect(tag).to_not receive(:mark_as_dirty!)
          destroy_list_item
        end

        it "returns an error status code" do
          destroy_list_item
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns JSON describing the errors" do
          destroy_list_item
          json = JSON.parse(response.body)
          expect(json.keys).to eq(%w[errors])
        end
      end
    end

    context "user has the `Redesigned lists` permission" do
      let(:tag) { create(:mainstream_browse_page, :published) }

      before do
        stub_any_publishing_api_call
      end

      it "destroys a list item and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: ["signin", "GDS Editor", "Redesigned lists"])

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
                  "contents" => [],
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
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        patch :destroy, params: {
          tag_id: tag.content_id,
          list_id: list.id,
          id: list_item.id,
        }

        expect(response.status).to eq(403)
      end
    end

    def destroy_list_item
      delete :destroy, params: {
        tag_id: tag.content_id,
        list_id: list.id,
        id: list_item.id,
        format: format,
      }
    end

    def stub_tag_class
      stubbed_list_item = double(
        "stubbed ListItem",
        destroy!: nil,
        destroyed?: false,
        errors: {
          "error_name": "Error description",
        },
      )
      stubbed_list = double("stubbed List", list_items: double("stubbed list_items", find: stubbed_list_item))
      stubbed_tag = double("stubbed Tag", to_param: tag.content_id, lists: double("stubbed lists", find: stubbed_list))
      stub_const("Tag", double("stubbed Tag class", find_by!: stubbed_tag))
    end
  end

  describe "GET confirm_destroy" do
    let(:list) { create(:list, tag: tag) }
    let!(:list_item) { create(:list_item, list: list) }

    context "Tag is a MainstreamBrowsePage" do
      let(:tag) { create(:mainstream_browse_page) }

      it "assigns the correct instance variables and renders the confirm_destroy template" do
        stub_user.update!(permissions: ["signin", "GDS Editor", "Redesigned lists"])

        get :confirm_destroy, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(assigns(:list_item).id).to eq list_item.id
        expect(response.status).to eq(200)
        expect(response).to render_template :confirm_destroy
      end

      it "does not allow users without GDS Editor permissions access" do
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        get :confirm_destroy, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(response.status).to eq(403)
      end
    end

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic) }

      it "assigns the correct instance vaiables and renders the confirm_destroy template" do
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        get :confirm_destroy, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(assigns(:list_item).id).to eq list_item.id
        expect(response.status).to eq(200)
        expect(response).to render_template :confirm_destroy
      end
    end
  end

  describe "GET move" do
    let(:list) { create(:list, tag: tag) }
    let!(:list_item) { create(:list_item, list: list) }

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

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic) }

      it "assign the correct instance vaiables and renders the move template" do
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        get :move, params: { tag_id: tag.content_id, list_id: list.id, id: list_item.id }

        expect(assigns(:tag).id).to eq tag.id
        expect(assigns(:list).id).to eq list.id
        expect(assigns(:list_item).id).to eq list_item.id
        expect(response.status).to eq(200)
        expect(response).to render_template :move
      end
    end
  end

  describe "PATCH update_move" do
    let(:list1) { create(:list, tag: tag) }
    let(:list2) { create(:list, tag: tag) }
    let!(:list_item1) { create(:list_item, list: list1, index: 1) }
    let!(:list_item2) { create(:list_item, list: list1, index: 2) }
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

      it "updates the list item to belong to list_id passed in and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: ["signin", "GDS Editor", "Redesigned lists"])

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
                  "contents" => [
                    list_item2.base_path,
                  ],
                },
                {
                  "name" => list2.name,
                  "contents" => [
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
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        patch :update_move, params: {
          tag_id: tag.content_id,
          list_id: list1.id,
          id: list_item1.id,
          list_item: { new_list_id: list2.id },
        }

        expect(response.status).to eq(403)
      end

      it "adds and error and renders the move view if a new_list_id is not passed in" do
        stub_user.update!(permissions: ["signin", "GDS Editor", "Redesigned lists"])

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

    context "Tag is a topic and user does not have `GDS Editor permissions`" do
      let(:tag) { create(:topic, :published) }

      it "updates the list item to belong to list_id passed in and makes the correct calls to the Publishing API" do
        stub_user.update!(permissions: ["signin", "Redesigned lists"])

        patch :update_move, params: {
          tag_id: tag.content_id,
          list_id: list1.id,
          id: list_item1.id,
          list_item: { new_list_id: list2.id },
        }

        expect(list1.reload.list_items.count).to eq 1
        expect(list2.reload.list_items.count).to eq 1
        expect(list2.list_items.first.index).to eq 1
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
                  "contents" => [
                    list_item2.base_path,
                  ],
                },
                {
                  "name" => list2.name,
                  "contents" => [
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
