require "rails_helper"

RSpec.describe ArchivedTagPresenter do
  let(:parent)   { create :mainstream_browse_page, slug: "parent", title: "Parent mainstream browse page", description: "Description of parent mainstream browse page." }
  let(:child)    { create :mainstream_browse_page, slug: "child-1", title: "Child mainstream browse page", description: "Description of child mainstream browse page.", parent: }

  describe "#render_for_publishing_api" do
    before(:each) do
      %w[child-1 child-1/latest].each do |route|
        child.redirect_routes.create!(from_base_path: "/mainstream_browse_page/parent/#{route}", to_base_path: parent.base_path, tag_id: child.id)
      end
    end

    it "renders a redirect to a parent with no subroutes correctly" do
      expected_child_content = {
        base_path: "/browse/parent/child-1",
        document_type: "redirect",
        schema_name: "redirect",
        publishing_app: "collections-publisher",
        redirects: [
          {
            path: "/mainstream_browse_page/parent/child-1",
            destination: "/browse/parent",
            type: "exact",
          },
          {
            path: "/mainstream_browse_page/parent/child-1/latest",
            destination: "/browse/parent",
            type: "exact",
          },
        ],
        update_type: "minor",
      }
      presenter = ArchivedTagPresenter.new(child)
      expect(presenter.render_for_publishing_api).to eq expected_child_content
    end

    it "is valid against the schemas" do
      presenter = ArchivedTagPresenter.new(child)

      expect(presenter.render_for_publishing_api).to be_valid_against_publisher_schema("redirect")
    end
  end

  describe "#base_path" do
    it "should return the original tag base path" do
      presenter = ArchivedTagPresenter.new(child)
      expect(presenter.base_path).to eq child.base_path
    end
  end
end
