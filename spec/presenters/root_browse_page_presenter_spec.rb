require 'rails_helper'

RSpec.describe RootBrowsePagePresenter do

  describe "#render_for_publishing_api" do
    it "raises a RunTimeError if top-level browse pages are not present" do
      expect {
        RootBrowsePagePresenter.new.render_for_publishing_api
      }.to raise_error(RuntimeError)
    end

    context "with top level browse pages" do

      let!(:top_level_page_1) { create(:mainstream_browse_page)}
      let!(:top_level_page_2) { create(:mainstream_browse_page)}

      let(:rendered) { RootBrowsePagePresenter.new.render_for_publishing_api}

      it "is valid against the schema" do
        expect(rendered).to be_valid_against_schema('mainstream_browse_page')
      end

      it "includes all the top-level browse pages" do
        expect(rendered[:links]["top_level_browse_pages"]).to eq([
          top_level_page_1.content_id,
          top_level_page_2.content_id,
        ])
      end
    end
  end
end
