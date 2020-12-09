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
end
