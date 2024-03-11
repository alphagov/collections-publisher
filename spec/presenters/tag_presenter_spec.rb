require "rails_helper"

RSpec.describe TagPresenter do
  describe "returning presenter for different tag types" do
    it "should return a MainstreamBrowsePagePresenter for a MainstreamBrowsePage" do
      expect(TagPresenter.presenter_for(MainstreamBrowsePage.new)).to be_a(MainstreamBrowsePagePresenter)
    end

    it "should raise an error for an unknown type" do
      expect {
        TagPresenter.presenter_for(Object.new)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#render_for_publishing_api" do
    let(:tag) do
      create(:mainstream_browse_page, parent: create(:tag, slug: "oil-and-gas"),
                                      slug: "offshore",
                                      title: "Offshore",
                                      description: "Oil rigs, pipelines etc.")
    end

    it "is valid against the schema without lists" do
      presented_data = MainstreamBrowsePagePresenter.new(tag).render_for_publishing_api

      expect(presented_data).to be_valid_against_publisher_schema("mainstream_browse_page")
    end

    it "is valid against the schema with lists" do
      create(:list, tag:, name: "List A")
      create(:list, tag:, name: "List B")

      # We need to "publish" these lists.
      allow_any_instance_of(List).to receive(:tagged_list_items).and_return(
        [OpenStruct.new(content_id: "5d2cd813-7631-11e4-a3cb-00505601111a")],
      )
      tag.update!(published_groups: GroupsPresenter.new(tag).groups, dirty: false)

      presented_data = MainstreamBrowsePagePresenter.new(tag).render_for_publishing_api

      expect(presented_data).to be_valid_against_publisher_schema("mainstream_browse_page")
    end

    it "uses the published groups if it's set" do
      tag.update! published_groups: { foo: "bar" }

      presented_data = MainstreamBrowsePagePresenter.new(tag).render_for_publishing_api

      expect(presented_data[:details][:groups]).to eql("foo" => "bar")
    end
  end
end
