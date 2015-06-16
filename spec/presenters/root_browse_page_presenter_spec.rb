require 'rails_helper'

RSpec.describe RootBrowsePagePresenter do

  describe "#render_for_publishing_api" do
    it "is valid against the schema without browse pages", :schema_test => true do
      rendered = RootBrowsePagePresenter.new.render_for_publishing_api

      expect(rendered).to be_valid_against_schema('mainstream_browse_page')
    end

    it "renders valid top level browse pages" do
      top_level_page_1 = create(:mainstream_browse_page)
      top_level_page_2 = create(:mainstream_browse_page)

      rendered = RootBrowsePagePresenter.new.render_for_publishing_api

      expect(rendered).to be_valid_against_schema('mainstream_browse_page')
      expect(rendered[:links]["top_level_browse_pages"]).to eq([
        top_level_page_1.content_id,
        top_level_page_2.content_id,
      ])
    end
  end
end
