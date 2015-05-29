require 'rails_helper'

RSpec.describe TagPresenter do

  describe 'returning presenter for different tag types' do
    it "should return a TopicPresenter for a Topic" do
      expect(TagPresenter.presenter_for(Topic.new)).to be_a(TopicPresenter)
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

  describe '#render_for_panopticon' do
    let(:attributes) {{
      slug: 'citizenship',
      title: 'Citizenship',
      description: 'Living in the UK, passports',
      parent: nil,
      tag_type: nil,
    }}

    it 'returns a hash of tag attributes' do
      tag = double(:tag, attributes)
      presenter = TagPresenter.new(tag)

      expect(presenter.render_for_panopticon).to eq(
        {
          tag_id: 'citizenship',
          title: 'Citizenship',
          tag_type: nil,
          description: 'Living in the UK, passports',
          parent_id: nil,
        }
      )
    end

    it 'builds a tag_id containing the parent' do
      child_tag = double(:tag, attributes.merge(
        parent: double(:tag, slug: 'parent')
      ))
      presenter = TagPresenter.new(child_tag)

      expect(presenter.render_for_panopticon[:tag_id]).to eq('parent/citizenship')
    end
  end

  describe "details hash" do
    let(:tag) do
      create(:tag, {
        :parent => create(:tag, :slug => 'oil-and-gas'),
        :slug => 'offshore',
        :title => 'Offshore',
        :description => 'Oil rigs, pipelines etc.',
      })
    end

    let(:presented_data) do
      TopicPresenter.new(tag).render_for_publishing_api
    end

    it "should contain an empty groups array with no curated lists" do
      expect(presented_data[:details]).to eq({
        :groups => [],
        :beta => false,
      })
    end

    context "with some curated lists" do
      let(:oil_rigs) { create(:list, :tag => tag, :index => 1, :name => 'Oil rigs') }
      let(:piping) { create(:list, :tag => tag, :index => 0, :name => 'Piping') }

      before :each do
        allow(oil_rigs).to receive(:tagged_list_items).and_return([
          OpenStruct.new(:api_url => "http://api.example.com/oil-rig-safety-requirements"),
          OpenStruct.new(:api_url => "http://api.example.com/oil-rig-staffing"),
        ])

        allow(piping).to receive(:tagged_list_items).and_return([
          OpenStruct.new(:api_url => "http://api.example.com/undersea-piping-restrictions"),
        ])

        allow(tag).to receive(:lists).and_return(double(:ordered => [piping, oil_rigs]))
      end

      it "provides the curated lists ordered by their index" do
        expect(presented_data[:details]).to eq({
          :groups => [
            {
              :name => "Piping",
              :contents => [
                "http://api.example.com/undersea-piping-restrictions",
              ]
            },
            {
              :name => "Oil rigs",
              :contents => [
                "http://api.example.com/oil-rig-safety-requirements",
                "http://api.example.com/oil-rig-staffing",
              ]
            }
          ],
          :beta => false,
        })
      end

      it "is valid against the schema", :schema_test => true do
        expect(presented_data).to be_valid_against_schema('topic')
      end
    end
  end
end
