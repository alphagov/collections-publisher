require 'rails_helper'

RSpec.describe SecondaryContentLinksController do
  let(:step_by_step_page) { create_step_by_step_page }

  describe "GET secondary content index page" do
    let(:secondary_content_link) { create(:secondary_content_link, step_by_step_page: step_by_step_page) }

    it "can only be accessed by users with GDS editor permissions" do
      stub_user.permissions << "GDS Editor"
      get :index, params: { step_by_step_page_id: step_by_step_page.id }

      expect(response.status).to eq(200)
    end

    it "cannot be accessed by users without GDS editor permissions" do
      stub_user.permissions = %w(signin)
      get :index, params: { step_by_step_page_id: step_by_step_page.id }

      expect(response.status).to eq(403)
    end
  end

  describe "#create" do
    it "adds a new secondary content link" do
      stub_user.permissions << "GDS Editor"

      allow(Services.publishing_api).to receive(:lookup_content_id).and_return("a-content-id")
      allow(Services.publishing_api).to receive(:get_content)
        .with("a-content-id")
        .and_return(content_item)
      allow(Services.publishing_api).to receive(:put_content)
      allow(Services.publishing_api).to receive(:lookup_content_ids).and_return([])

      post :create, params: { step_by_step_page_id: step_by_step_page.id, base_path: "/base_path" }

      expect(step_by_step_page.secondary_content_links.first.base_path).to eq("/base_path")
      expect(step_by_step_page.secondary_content_links.first.content_id).to eq("a-content-id")
      expect(step_by_step_page.secondary_content_links.first.title).to eq("A Title")
    end

    it "returns an error if the base_path does not exist" do
      stub_user.permissions << "GDS Editor"

      allow(Services.publishing_api).to receive(:lookup_content_id).and_return(nil)

      post :create, params: { step_by_step_page_id: step_by_step_page.id, base_path: "/base_path" }
      expect(flash[:alert]).to be_present
    end

    it "accepts a full url as the base_path" do
      stub_user.permissions << "GDS Editor"

      allow(Services.publishing_api).to receive(:lookup_content_id).and_return("a-content-id")
      allow(Services.publishing_api).to receive(:get_content).and_return(content_item)
      allow(Services.publishing_api).to receive(:put_content)
      allow(Services.publishing_api).to receive(:lookup_content_ids).and_return([])

      post :create, params: { step_by_step_page_id: step_by_step_page.id, base_path: "http:/foo.com/base_path" }

      expect(step_by_step_page.secondary_content_links.first.base_path).to eq("/base_path")
    end
  end

  describe "#destroy" do
    it "removes a secondary content link" do
      stub_user.permissions << "GDS Editor"
      allow(Services.publishing_api).to receive(:put_content)

      create(:secondary_content_link, step_by_step_page: step_by_step_page)

      post :destroy, params: { step_by_step_page_id: step_by_step_page.id, id: step_by_step_page.secondary_content_links.first.id }

      expect(step_by_step_page.secondary_content_links.count).to eq(0)
    end
  end

  def create_step_by_step_page
    build(:step_by_step_page_with_secondary_content).tap do |step_page|
      step_page.save(validate: false)
    end
  end

  def content_item
    {
      "content_id" => "a-content-id",
      "base_path" => "/base_path",
      "title" => "A Title",
      "publishing_app" => "publisher",
      "schema_name" => "guide",
    }
  end
end
