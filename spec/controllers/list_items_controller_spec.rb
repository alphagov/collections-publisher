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
          expect(flash.key?(:success)).to be(true)
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
          expect(flash.key?(:danger)).to be(true)
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
          expect(flash.key?(:success)).to be(true)
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
          expect(flash.key?(:danger)).to be(true)
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

    def destroy_list_item
      delete :destroy, params: {
        tag_id: tag.content_id,
        list_id: list.id,
        id: list_item.id,
        format: format,
      }
    end

    class StubbedTag
      def initialize(tag)
        @tag = tag
      end

      def find_by!(_content_id)
        @tag
      end
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
      stub_const("Tag", StubbedTag.new(stubbed_tag))
    end
  end
end
