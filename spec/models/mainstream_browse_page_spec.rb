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

end
