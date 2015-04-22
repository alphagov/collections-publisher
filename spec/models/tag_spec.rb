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

describe Tag do

  describe "validations" do
    let(:tag) { build(:tag) }
    let(:parent) { create(:tag, :slug => 'parent') }

    it 'is created with valid attributes' do
      expect(tag).to be_valid
      expect(tag.save).to be_true
      expect(tag).to be_persisted
    end

    it "requires a title" do
      tag.title = ''

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:title)
    end

    describe "on slug" do
      it "is required" do
        tag.slug = ''
        expect(tag).not_to be_valid
        expect(tag.errors).to have_key(:slug)
      end

      describe 'uniqueness' do
        it 'is invalid when there is no parent and the slug already exists' do
          parent # instansiate the parent
          tag.slug = 'parent'

          expect(tag).not_to be_valid
          expect(tag.errors).to have_key(:slug)
        end

        it 'is valid when the slug has been taken by a tag with a different parent' do
          different_parent = create(:tag)
          create(:tag, :slug => 'passports', :parent => different_parent)

          tag.parent = parent
          tag.slug = 'passports'
          expect(tag).to be_valid
        end

        it 'is invalid when the slug has been taken by a tag with the same parent' do
          create(:tag, slug: 'passports', :parent => parent)

          tag.parent = parent
          tag.slug = 'passports'
          expect(tag).not_to be_valid
          expect(tag.errors).to have_key(:slug)
        end
      end
    end

    it 'is invalid when its parent has a parent' do
      first_child = create(:tag, parent: parent)
      tag.parent = first_child

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:parent)
    end
  end

  it 'can be created with a parent' do
    parent = create(:tag)
    tag = Tag.create!(
      slug: 'child',
      parent: parent,
      title: 'Child browse page'
    )
    tag.reload

    expect(tag.parent_id).to eq(parent.id)
  end


  describe 'state' do
    let(:tag) { create(:tag) }

    it 'is created in a draft state' do
      expect(tag.state).to eq('draft')
      expect(tag).to be_draft
    end

    it 'can be published' do
      expect(tag.publish).to be_true

      expect(tag.state).to eq('published')
      expect(tag).to be_published
    end

    it "can't be published twice" do
      tag.publish

      expect { tag.publish }.to raise_error(AASM::InvalidTransition)
    end

    it 'raises exception when a value is assigned to state' do
      expect {
        tag.state = 'draft'
      }.to raise_error(NoMethodError, /private method/)
    end
  end

  describe '#can_have_children?' do
    it 'returns true when parent_id is empty' do
      tag = create(:tag, parent: nil)

      expect(tag.can_have_children?).to be_true
    end

    it 'returns false when parent_id is present' do
      parent = create(:tag)
      tag = create(:tag, parent: parent)

      expect(tag.can_have_children?).to be_false
    end
  end

  describe 'generating a content ID' do

    it 'generates a UUID on creation' do
      expect(SecureRandom).to receive(:uuid).and_return('a random UUID')
      tag = create(:tag)

      expect(tag.content_id).to eq('a random UUID')
    end

    it 'is invalid without a content ID' do
      tag = build(:tag, content_id: '')

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:content_id)
    end

  end

  describe '#base_path' do
    it 'returns the slug for a parent tag' do
      tag = build(:tag, slug: 'example')

      expect(tag.base_path).to eq('/example')
    end

    it 'joins the parent slug for a child tag' do
      parent = create(:tag)
      tag = build(:tag, slug: 'example', parent: parent)

      expect(tag.base_path).to eq("/#{parent.slug}/example")
    end
  end

  it 'does not allow changing the slug for a published tag' do
    tag = create(:tag, slug: 'example')
    tag.publish
    tag.slug = 'a-different-slug'

    expect(tag).not_to be_valid
    expect(tag.errors).to have_key(:slug)
  end
end
