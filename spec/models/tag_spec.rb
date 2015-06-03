require 'rails_helper'

RSpec.describe Tag do
  include ContentApiHelpers

  describe "validations" do
    let(:tag) { build(:tag) }
    let(:parent) { create(:tag, :slug => 'parent') }

    it 'is created with valid attributes' do
      expect(tag).to be_valid
      expect(tag.save).to eql true
      expect(tag).to be_persisted
    end

    it 'requires a unique content_id at db level' do
      duplicate = create(:tag)
      tag.content_id = duplicate.content_id

      expect {
        tag.save :validate => false
      }.to raise_error(ActiveRecord::RecordNotUnique)
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

      it "must be a valid slug" do
        [
          'foo/bar',
          'under_score',
          'space space',
          'MixEd-Case',
        ].each do |slug|
          tag.slug = slug
          expect(tag).not_to be_valid
          expect(tag.errors).to have_key(:slug)
        end
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
      expect(tag.publish).to eql true

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
      }.to raise_error(AASM::NoDirectAssignmentError)
    end
  end

  describe '#can_have_children?' do
    it 'returns true when parent_id is empty' do
      tag = create(:tag, parent: nil)

      expect(tag.can_have_children?).to eql true
    end

    it 'returns false when parent_id is present' do
      parent = create(:tag)
      tag = create(:tag, parent: parent)

      expect(tag.can_have_children?).to eql false
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

  it 'does not allow changing the slug for an existing tag' do
    tag = create(:tag, slug: 'example')
    tag.slug = 'a-different-slug'

    expect(tag).not_to be_valid
    expect(tag.errors).to have_key(:slug)
  end

  describe "dirty tracking" do
    describe "mark_as_dirty!" do
      let(:tag) { create(:tag, :title => "Title") }

      it "sets the dirty flag" do
        tag.mark_as_dirty!

        tag.reload
        expect(tag).to be_dirty
      end

      it "doesn't save any other changes to the topic" do
        tag.title = "Changed title"
        tag.mark_as_dirty!

        tag.reload
        expect(tag).to be_dirty
        expect(tag.title).to eq("Title")
      end
    end

    describe "clearing the dirty flag" do
      let(:tag) { create(:tag, :draft, :title => "Title", :dirty => true) }

      it "mark_as_clean! sets dirty to false and saves" do
        tag.mark_as_clean!
        tag.reload
        expect(tag).not_to be_dirty
      end

      it "doesn't save any other changes to the topic" do
        tag.title = "Changed title"
        tag.mark_as_clean!

        tag.reload
        expect(tag).not_to be_dirty
        expect(tag.title).to eq("Title")
      end
    end
  end

  describe "lists association" do
    let(:tag) { create(:tag) }
    let!(:list1) { create(:list, :tag => tag) }
    let!(:list2) { create(:list, :tag => tag) }
    let!(:list3) { create(:list) }

    it "returns all lists for the tag" do
      expect(tag.lists).to match_array([list1, list2])
    end

    it "should efficiently traverse the relationships" do
      # Ensures that memoised values on the tag model are efficiently used.

      dereferenced_tag = tag.lists.first.tag
      expect(dereferenced_tag.object_id).to eq(tag.object_id)
    end

    it "deletes lists when the tag is deleted" do
      tag.destroy

      expect(List.find_by_id(list1.id)).not_to be
      expect(List.find_by_id(list2.id)).not_to be
      expect(List.find_by_id(list3.id)).to be
    end
  end

  describe '#uncategorized_list_items' do
    let(:tag) { create(:tag, :slug => 'tag') }
    let(:subtag) { create(:tag, :parent => tag, :slug => 'subtag') }

    it "returns ListItems for all content that's been tagged to the tag, but isn't in a list" do
      list1 = create(:list, :tag => subtag)
      create(:list_item, :list => list1, :api_url => contentapi_url_for_slug('content-1'))
      list2 = create(:list, :tag => subtag)
      create(:list_item, :list => list2, :api_url => contentapi_url_for_slug('content-3'))

      content_api_has_artefacts_with_a_tag('tag', 'tag/subtag', [
        'content-1',
        'content-2',
        'content-3',
        'content-4',
      ])

      expect(subtag.uncategorized_list_items.map(&:api_url)).to match_array([
        contentapi_url_for_slug('content-2'),
        contentapi_url_for_slug('content-4'),
      ])
    end
  end

  describe '#untagged_list_items' do
    let(:tag) { create(:tag, :slug => 'tag') }
    let(:subtag) { create(:tag, :parent => tag, :slug => 'subtag') }

    before :each do
      list1 = create(:list, :tag => subtag)
      create(:list_item, :list => list1, :api_url => contentapi_url_for_slug('content-1'))
      create(:list_item, :list => list1, :api_url => contentapi_url_for_slug('content-2'))
      list2 = create(:list, :tag => subtag)
      create(:list_item, :list => list2, :api_url => contentapi_url_for_slug('content-3'))
    end

    it "returns all list items for content that's no longer tagged to the tag" do
      content_api_has_artefacts_with_a_tag('tag', 'tag/subtag', [
        'content-1',
        'content-3',
      ])

      expect(subtag.untagged_list_items.map(&:api_url)).to eq([
        contentapi_url_for_slug('content-2'),
      ])
    end

    it "returns empty array if all list items' content is tagged to the tag" do
      content_api_has_artefacts_with_a_tag('tag', 'tag/subtag', [
        'content-1',
        'content-2',
        'content-3',
      ])

      expect(subtag.untagged_list_items.map(&:api_url)).to eq([])
    end
  end

  describe '#list_items_from_contentapi' do
    let(:tag) { create(:tag, :slug => 'tag') }
    let(:subtag) { create(:tag, :parent => tag, :slug => 'subtag') }

    it "returns the ListItem instances for all content tagged to the tag" do
      content_api_has_artefacts_with_a_tag('tag', 'tag/subtag', [
        'example-content-1',
        'example-content-2'
      ])

      items = subtag.list_items_from_contentapi

      expect(items.map(&:api_url)).to eq([
        contentapi_url_for_slug('example-content-1'),
        contentapi_url_for_slug('example-content-2'),
      ])
      expect(items.map(&:title)).to eq([
        "Example content 1",
        "Example content 2"
      ])
      expect(items.first).to be_a(ListItem)
    end

    it "returns empty array when no items are tagged to the tag" do
      content_api_has_artefacts_with_a_tag('tag', 'tag/subtag', [])

      expect(subtag.list_items_from_contentapi).to eq([])
    end

    it "returns empty array when no topic exists in content api" do
      stub_request(:get, %r[.]).to_return(status: 404)

      expect(subtag.list_items_from_contentapi).to eq([])
    end

    it "returns the correct info for a browse page" do
      parent = create(:mainstream_browse_page, slug: 'benefits')
      browse_page = create(:mainstream_browse_page, parent: parent, slug: 'entitlement')
      content_api_has_artefacts_with_a_tag('section', 'benefits/entitlement', [
        'example-content-1',
        'example-content-2'
      ])

      items = browse_page.list_items_from_contentapi

      expect(items.map(&:title)).to eq([
        "Example content 1",
        "Example content 2"
      ])
    end
  end
end
