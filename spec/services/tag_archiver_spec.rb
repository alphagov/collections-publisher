require "rails_helper"

RSpec.describe TagArchiver do
  describe '#archive' do
    before do
      # By default make it so that there's nothing tagged to topics.
      stub_any_call_to_rummager_with_documents([])

      # Succesful archivings will remove the result from rummager.
      allow(CollectionsPublisher.services(:rummager)).to receive(:delete_document)
    end

    it "won't archive parent tags" do
      tag = create(:topic)

      TagArchiver.new(tag, build(:topic)).archive
      tag.reload

      expect(tag.archived).to be(false)
    end

    it "won't archive tags with documents tagged to it" do
      tag = create(:topic, parent: create(:topic))
      stub_any_call_to_rummager_with_documents([
        { link: '/content-page-1' },
        { link: '/content-page-2' },
      ])

      TagArchiver.new(tag, build(:topic)).archive
      tag.reload

      expect(tag.archived).to be(false)
    end

    it "archives the tag" do
      tag = create(:topic, parent: create(:topic))

      TagArchiver.new(tag, build(:topic)).archive
      tag.reload

      expect(tag.archived).to be(true)
    end

    it "creates a redirect to its successor" do
      tag = create(:topic, parent: create(:topic))
      successor = create(:topic)

      TagArchiver.new(tag, successor).archive
      redirect = tag.redirects.first

      expect(redirect.from_base_path).to eql tag.base_path
      expect(redirect.to_base_path).to eql successor.base_path
    end

    it "creates redirects for the suffixes" do
      tag = create(:topic, slug: 'bar', parent: create(:topic, slug: 'foo'))
      successor = create(:topic)

      TagArchiver.new(tag, successor).archive

      expect(tag.redirects.map(&:from_base_path)).to eql([
        "/topic/foo/bar",
        "/topic/foo/bar/latest",
        "/topic/foo/bar/email-signup",
      ])
    end

    it "redirects to the base path when the successor is a parent topic" do
      tag = create(:topic, parent: create(:topic))
      successor = create(:topic, slug: 'foo')

      TagArchiver.new(tag, successor).archive

      expect(tag.redirects.map(&:to_base_path)).to eql([
        "/topic/foo",
        "/topic/foo",
        "/topic/foo",
      ])
    end

    it "redirects to the suffixes when the successor is a child topic" do
      tag = create(:topic, parent: create(:topic))
      successor = create(:topic, slug: 'bar', parent: create(:topic, slug: 'foo'))

      TagArchiver.new(tag, successor).archive

      expect(tag.redirects.map(&:to_base_path)).to eql([
        "/topic/foo/bar",
        "/topic/foo/bar/latest",
        "/topic/foo/bar/email-signup",
      ])
    end

    it "removes the document from the search result" do
      tag = create(:topic, parent: create(:topic))

      TagArchiver.new(tag, build(:topic)).archive

      expect(CollectionsPublisher.services(:rummager)).to have_received(:delete_document)
    end

    it "doesn't have side effects when a API call fails" do
      tag = create(:topic, parent: create(:topic))
      allow(CollectionsPublisher.services(:rummager)).to receive(:delete_document).and_raise(RuntimeError)

      expect { TagArchiver.new(tag, build(:topic)).archive }.to raise_error(RuntimeError)
      tag.reload

      expect(tag.archived).to be(false)
      expect(tag.redirects.size).to be(0)
    end
  end
end
