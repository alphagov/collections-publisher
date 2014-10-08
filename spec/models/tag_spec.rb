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

  describe 'slug uniqueness' do
    
    it 'is invalid when there is no parent and the slug already exists' do
      create(:tag, slug: 'passports')
      tag = Tag.new(
        valid_atts.merge(slug: 'passports')
      )

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:slug)
    end

    it 'is valid when the slug has been taken by a tag with a different parent' do
      create(:tag, slug: 'passports', parent: parent)
      different_parent = create(:tag)

      tag = Tag.new(
        valid_atts.merge(slug: 'passports', parent: different_parent)
      )

      expect(tag).to be_valid
    end

    it 'is invalid when the slug has been taken by a tag with the same parent' do
      create(:tag, slug: 'passports', parent: parent)

      tag = Tag.new(
        valid_atts.merge(slug: 'passports', parent: parent)
      )
      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:slug)
    end
  end

  describe 'generating a content ID' do

    it 'generates a UUID on creation' do
      expect(SecureRandom).to receive(:uuid).and_return('a random UUID')
      tag = create(:tag)

      expect(tag.content_id).to eq('a random UUID')
    end

    it 'is invalid without a content ID' do
      tag = Tag.new(
        valid_atts.merge(content_id: '')
      )

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:content_id)
    end

  end

end
