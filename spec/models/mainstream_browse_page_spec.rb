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
end
