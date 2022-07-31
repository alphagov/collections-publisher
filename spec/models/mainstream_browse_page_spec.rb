require "rails_helper"

RSpec.describe MainstreamBrowsePage do
  it "is created with valid attributes" do
    tag = MainstreamBrowsePage.new(
      slug: "housing",
      title: "Housing",
      description: "All about housing",
    )

    expect(tag).to be_valid
    expect(tag.save).to eql true
    expect(tag).to be_persisted
  end

  describe "#base_path" do
    it "prepends /browse to the base_path" do
      tag = create(:mainstream_browse_page)
      expect(tag.base_path).to eq("/browse/#{tag.slug}")
    end
  end

  describe "#can_be_archived?" do
    it "returns true for published level two mainstream browse page" do
      mainstream_browse_page = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))

      expect(mainstream_browse_page.can_be_archived?).to eql(true)
    end

    it "returns false for draft level two mainstream browse page" do
      mainstream_browse_page = create(:mainstream_browse_page, :draft, parent: create(:mainstream_browse_page))

      expect(mainstream_browse_page.can_be_archived?).to eql(false)
    end

    it "returns false for archived level two mainstream browse page" do
      mainstream_browse_page = create(:mainstream_browse_page, :archived, parent: create(:mainstream_browse_page))

      expect(mainstream_browse_page.can_be_archived?).to eql(false)
    end

    it "returns false for level one mainstream browse page" do
      mainstream_browse_page = create(:mainstream_browse_page, :published, parent: nil, children: [create(:mainstream_browse_page, :draft)])

      expect(mainstream_browse_page.can_be_archived?).to eql(false)
    end
  end
end
