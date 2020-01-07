require "rails_helper"

RSpec.describe TagPresenter do
  describe "returning presenter for different tag types" do
    context "Topics" do
      let(:topic) { Topic.new }

      it "should return a TopicPresenter for a draft Topic" do
        expect(topic).to receive(:state).and_return("draft")
        expect(TagPresenter.presenter_for(topic)).to be_a(TopicPresenter)
      end

      it "should return a TopicPresenter for a published topic" do
        expect(topic).to receive(:state).and_return("published")
        expect(TagPresenter.presenter_for(topic)).to be_a(TopicPresenter)
      end

      it "should return an ArchivedTagPresenter for an archived topic" do
        expect(topic).to receive(:state).and_return("archived")
        expect(TagPresenter.presenter_for(topic)).to be_a(ArchivedTagPresenter)
      end
    end

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
      create(:topic, parent: create(:tag, slug: "oil-and-gas"),
        slug: "offshore",
        title: "Offshore",
        description: "Oil rigs, pipelines etc.")
    end

    it "is valid against the schema without lists" do
      presented_data = TopicPresenter.new(tag).render_for_publishing_api

      expect(presented_data).to be_valid_against_schema("topic")
    end

    it "is valid against the schema with lists" do
      create(:list, tag: tag, name: "List A")
      create(:list, tag: tag, name: "List B")

      # We need to "publish" these lists.
      allow_any_instance_of(List).to receive(:tagged_list_items).and_return(
        [OpenStruct.new(base_path: "/oil-rig-safety-requirements")],
      )
      tag.update!(published_groups: GroupsPresenter.new(tag).groups, dirty: false)

      presented_data = TopicPresenter.new(tag).render_for_publishing_api

      expect(presented_data).to be_valid_against_schema("topic")
    end

    it "uses the published groups if it's set" do
      tag.update! published_groups: { foo: "bar" }

      presented_data = TopicPresenter.new(tag).render_for_publishing_api

      expect(presented_data[:details][:groups]).to eql("foo" => "bar")
    end
  end
end
