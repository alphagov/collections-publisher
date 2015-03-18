require 'spec_helper'

describe TagPresenter do

  let(:attributes) {
    {
      slug: 'citizenship',
      title: 'Citizenship',
      description: 'Living in the UK, passports',
      parent: nil,
    }
  }

  describe '#render_for_panopticon' do
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
