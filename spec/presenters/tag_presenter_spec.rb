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

end
