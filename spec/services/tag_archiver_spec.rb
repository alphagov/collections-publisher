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
      redirect = tag.redirects.last

      expect(redirect.from_base_path).to eql tag.base_path
      expect(redirect.to_base_path).to eql successor.base_path
    end

    it "removes the document from the search result" do
      tag = create(:topic, parent: create(:topic))

      TagArchiver.new(tag, build(:topic)).archive

      expect(CollectionsPublisher.services(:rummager)).to have_received(:delete_document)
    end
  end
end
