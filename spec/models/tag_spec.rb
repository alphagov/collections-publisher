require 'spec_helper'

describe Tag do

  let(:parent) { create(:tag) }
  let(:valid_atts) { attributes_for(:tag) }

  it 'is created with valid attributes' do
    tag = Tag.new(
      slug: 'housing',
      title: 'Housing',
      description: 'All about housing'
    )

    expect(tag).to be_valid
    expect(tag.save).to be_true
    expect(tag).to be_persisted
  end

  it 'can be created with a parent' do
    tag = Tag.create!(
      slug: 'child',
      parent: parent,
      title: 'Child browse page'
    )
    tag.reload

    expect(tag.parent_id).to eq(parent.id)
  end

  it 'is invalid without a slug' do
    tag = Tag.new(
      valid_atts.merge(slug: nil)
    )

    expect(tag).not_to be_valid
    expect(tag.errors).to have_key(:slug)
  end

  it 'is invalid without a title' do
    tag = Tag.new(
      valid_atts.merge(title: nil)
    )

    expect(tag).not_to be_valid
    expect(tag.errors).to have_key(:title)
  end

  it 'is invalid when its parent has a parent' do
    first_child = create(:tag, parent: parent)
    tag = Tag.new(
      valid_atts.merge(parent: first_child)
    )

    expect(tag).not_to be_valid
    expect(tag.errors).to have_key(:parent)
  end

end
