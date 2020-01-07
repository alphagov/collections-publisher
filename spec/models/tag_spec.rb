require "rails_helper"

RSpec.describe Tag do
  describe "#published_groups" do
    it "has an empty array as default value" do
      tag = Tag.new

      expect(tag.published_groups).to eql([])
    end
  end

  describe "validations" do
    let(:tag) { build(:tag) }
    let(:parent) { create(:tag, slug: "parent") }

    it "is created with valid attributes" do
      expect(tag).to be_valid
      expect(tag.save).to eql true
      expect(tag).to be_persisted
    end

    it "requires a unique content_id at db level" do
      duplicate = create(:tag)
      tag.content_id = duplicate.content_id

      expect {
        tag.save validate: false
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "requires a title" do
      tag.title = ""

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:title)
    end

    it "must have a valid ordering type" do
      tag.child_ordering = "from-E-to-D"

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:child_ordering)
    end

    describe "on slug" do
      it "is required" do
        tag.slug = ""
        expect(tag).not_to be_valid
        expect(tag.errors).to have_key(:slug)
      end

      it "must be a valid slug" do
        [
          "foo/bar",
          "under_score",
          "space space",
          "MixEd-Case",
        ].each do |slug|
          tag.slug = slug
          expect(tag).not_to be_valid
          expect(tag.errors).to have_key(:slug)
        end
      end

      describe "uniqueness" do
        it "is invalid when there is no parent and the slug already exists" do
          parent # instansiate the parent
          tag.slug = "parent"

          expect(tag).not_to be_valid
          expect(tag.errors).to have_key(:slug)
        end

        it "is valid when the slug has been taken by a tag with a different parent" do
          different_parent = create(:tag)
          create(:tag, slug: "passports", parent: different_parent)

          tag.parent = parent
          tag.slug = "passports"
          expect(tag).to be_valid
        end

        it "is invalid when the slug has been taken by a tag with the same parent" do
          create(:tag, slug: "passports", parent: parent)

          tag.parent = parent
          tag.slug = "passports"
          expect(tag).not_to be_valid
          expect(tag.errors).to have_key(:slug)
        end
      end
    end

    it "is invalid when its parent has a parent" do
      first_child = create(:tag, parent: parent)
      tag.parent = first_child

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:parent)
    end
  end

  it "can be created with a parent" do
    parent = create(:tag)
    tag = Tag.create!(
      slug: "child",
      parent: parent,
      title: "Child browse page",
    )
    tag.reload

    expect(tag.parent_id).to eq(parent.id)
  end


  describe "state" do
    let(:tag) { create(:tag) }

    it "is created in a draft state" do
      expect(tag.state).to eq("draft")
      expect(tag).to be_draft
    end

    it "can be published" do
      expect(tag.publish).to eql true

      expect(tag.state).to eq("published")
      expect(tag).to be_published
    end

    it "can't be published twice" do
      tag.publish

      expect { tag.publish }.to raise_error(AASM::InvalidTransition)
    end

    it "raises exception when a value is assigned to state" do
      expect {
        tag.state = "draft"
      }.to raise_error(AASM::NoDirectAssignmentError)
    end
  end

  describe "#can_have_children?" do
    it "returns true when parent_id is empty" do
      tag = create(:tag, parent: nil)

      expect(tag.can_have_children?).to eql true
    end

    it "returns false when parent_id is present" do
      parent = create(:tag)
      tag = create(:tag, parent: parent)

      expect(tag.can_have_children?).to eql false
    end
  end

  describe "generating a content ID" do
    it "generates a UUID on creation" do
      expect(SecureRandom).to receive(:uuid).and_return("a random UUID")
      tag = create(:tag)

      expect(tag.content_id).to eq("a random UUID")
    end

    it "is invalid without a content ID" do
      tag = build(:tag, content_id: "")

      expect(tag).not_to be_valid
      expect(tag.errors).to have_key(:content_id)
    end
  end

  describe "#full_slug" do
    it "returns the slug for a parent tag" do
      tag = build(:tag, slug: "example")

      expect(tag.full_slug).to eq("example")
    end

    it "joins the parent slug for a child tag" do
      parent = create(:tag)
      tag = build(:tag, slug: "example", parent: parent)

      expect(tag.full_slug).to eq("#{parent.slug}/example")
    end
  end

  it "does not allow changing the slug for an existing tag" do
    tag = create(:tag, slug: "example")
    tag.slug = "a-different-slug"

    expect(tag).not_to be_valid
    expect(tag.errors).to have_key(:slug)
  end

  describe "dirty tracking" do
    describe "mark_as_dirty!" do
      let(:tag) { create(:tag, title: "Title") }

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
  end

  describe "lists association" do
    let(:tag) { create(:tag) }
    let!(:list1) { create(:list, tag: tag) }
    let!(:list2) { create(:list, tag: tag) }
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

      expect(List.find_by(id: list1.id)).not_to be
      expect(List.find_by(id: list2.id)).not_to be
      expect(List.find_by(id: list3.id)).to be
    end
  end

  describe "#uncurated_tagged_documents" do
    let(:tag) { create(:tag, slug: "a-tag") }
    let(:subtag) { create(:tag, parent: tag, slug: "a-subtag") }

    it "returns items for all content that's been tagged to the tag, but isn't in a list" do
      list1 = create(:list, tag: subtag)
      create(:list_item, list: list1, base_path: "/content-page-1")
      list2 = create(:list, tag: subtag)
      create(:list_item, list: list2, base_path: "/content-page-3")

      publishing_api_has_linked_items(
        subtag.content_id,
        items: [
          { base_path: "/content-page-1" },
          { base_path: "/content-page-2" },
          { base_path: "/content-page-3" },
          { base_path: "/content-page-4" },
        ],
      )

      expect(subtag.uncurated_tagged_documents.map(&:base_path)).to match_array([
        "/content-page-2",
        "/content-page-4",
      ])
    end
  end
end
