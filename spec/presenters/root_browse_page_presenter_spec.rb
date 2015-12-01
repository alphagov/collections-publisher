require 'rails_helper'

RSpec.describe RootBrowsePagePresenter do
  describe "#render_for_publishing_api" do
    it "raises if top-level browse pages are not present" do
      expect {
        RootBrowsePagePresenter.new('state' => 'draft').render_for_publishing_api
      }.to raise_error(RuntimeError)
    end

    it "is valid against the schema" do
      create(:mainstream_browse_page, title: "Top-Level Page 1")
      create(:mainstream_browse_page, title: "Top-Level Page 2")

      rendered = RootBrowsePagePresenter.new('state' => 'draft').render_for_publishing_api
      expect(rendered).to be_valid_against_schema('mainstream_browse_page')
    end

    it "includes draft and published top-level browse pages" do
      page_1 = create(:mainstream_browse_page, :published, title: "Top-Level Page 1")
      page_2 = create(:mainstream_browse_page, :draft, title: "Top-Level Page 2")

      rendered = RootBrowsePagePresenter.new('state' => 'draft').render_for_publishing_api

      expect(rendered[:links]["top_level_browse_pages"]).to eq([
        page_1.content_id,
        page_2.content_id,
      ])
    end

    it ":public_updated_at equals the time of last browse page update" do
      page_1 = create(:mainstream_browse_page, title: "Top-Level Page 1")
      page_2 = create(:mainstream_browse_page, title: "Top-Level Page 2")

      Timecop.travel 3.hours.ago do
        page_1.touch
      end
      page_2.touch

      rendered = RootBrowsePagePresenter.new('state' => 'draft').render_for_publishing_api

      expect(rendered[:public_updated_at]).to eq(page_2.updated_at.iso8601)
    end
  end


  describe '#draft?' do
    it 'should return false if instantiated with a parameter of true' do
      presenter = RootBrowsePagePresenter.new('state' => 'published]')
      expect(presenter.draft?).to be false
    end

    it 'should return true if instantiated with a parameter of false' do
      presenter = RootBrowsePagePresenter.new('state' => 'draft')
      expect(presenter.draft?).to be true
    end
  end
end
