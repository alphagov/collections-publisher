require "rails_helper"

RSpec.describe TagArchiver do
  describe "#archive" do
    let(:content_item_data) do
      {
        "base_path" => "/successor_base_path",
        "title" => "Successor title",
        "content_id" => "a-content-id",
        "description" => "foo",
        "document_type" => "document_collection",
        "details" => {},
        "links" => {},
      }
    end
    let(:content_item_successor) { ContentItem.new(content_item_data) }
    let(:mainstream_browse_page_successor) { create(:mainstream_browse_page) }

    before do
      stub_any_publishing_api_call

      allow(Services.publishing_api).to receive(:put_content)
    end

    it "doesn't have side effects when the call to publishing API fails" do
      tag = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))

      expect(Services.publishing_api).to receive(:put_content).and_raise("publishing API call failed")
      expect { TagArchiver.new(tag, content_item_successor).archive }.to raise_error("publishing API call failed")
      tag.reload

      expect(tag.archived?).to be(false)
      expect(tag.redirect_routes.size).to be(0)
    end

    context "when archiving mainstream browse pages" do
      it "won't archive parent (level 1) mainstream_browse_page tags" do
        tag = create(:mainstream_browse_page, :published)

        expect { TagArchiver.new(tag, build(:mainstream_browse_page)).archive }.to raise_error(RuntimeError)
      end

      it "archives the level 2 mainstream_browse_page tags" do
        tag = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))

        TagArchiver.new(tag, mainstream_browse_page_successor).archive
        tag.reload

        expect(tag.archived?).to be(true)
      end

      it "creates a redirect to its successor" do
        tag = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))

        TagArchiver.new(tag, mainstream_browse_page_successor).archive
        redirect = tag.redirect_routes.first

        expect(redirect.from_base_path).to eql tag.base_path
        expect(redirect.to_base_path).to eql mainstream_browse_page_successor.base_path
      end

      it "creates redirects for the suffixes" do
        tag = create(:mainstream_browse_page, :published, slug: "bar", parent: create(:mainstream_browse_page, slug: "foo"))

        TagArchiver.new(tag, mainstream_browse_page_successor).archive

        expect(tag.redirect_routes.map(&:from_base_path)).to eql([
          "/browse/foo/bar",
          "/browse/foo/bar.json",
        ])
      end

      it "republishes the content item" do
        tag = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))

        TagArchiver.new(tag, mainstream_browse_page_successor).archive

        expect(Services.publishing_api).to have_received(:put_content)
      end
    end
  end
end
