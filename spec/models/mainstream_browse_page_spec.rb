# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  slug        :string(255)      not null
#  title       :string(255)      not null
#  description :string(255)
#  parent_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#  content_id  :string(255)      not null
#  state       :string(255)      not null
#
# Indexes
#
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#

require 'spec_helper'

describe MainstreamBrowsePage do

  it 'is created with valid attributes' do
    tag = MainstreamBrowsePage.new(
      slug: 'housing',
      title: 'Housing',
      description: 'All about housing'
    )

    expect(tag).to be_valid
    expect(tag.save).to be_true
    expect(tag).to be_persisted
  end

  describe '#base_path' do
    it 'prepends /browse to the base_path' do
      tag = create(:mainstream_browse_page)
      expect(tag.base_path).to eq("/browse/#{tag.slug}")
    end
  end

end
