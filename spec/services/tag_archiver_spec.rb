require "rails_helper"

RSpec.describe TagArchiver do
  describe "#archive" do
    let(:email_alert_api) { instance_double(GdsApi::EmailAlertApi) }
    let(:email_alert_updater) { class_double(EmailAlertApi::SubscriberListUpdater) }
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

      allow(Services).to receive(:email_alert_api).and_return(email_alert_api)
      allow(email_alert_api).to receive(:bulk_unsubscribe)
      allow(email_alert_api).to receive(:find_subscriber_list).and_return(
        { "subscriber_list" => { "slug" => "subscriber-list-slug" } },
      )
    end

    it "doesn't have side effects when the call to publishing API fails" do
      tag = create(:topic, :published, parent: create(:topic))

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
        tag = create(:mainstream_browse_page, :published, parent: create(:topic))

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

      it "does not call the email alert updater" do
        tag = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))
        any_successor = create(:mainstream_browse_page)

        expect(email_alert_updater).to receive(:call).with(item: tag, successor: any_successor).never
        TagArchiver.new(tag, any_successor).archive
      end
    end

    context "when archiving specialist topics" do
      it "won't archive parent (level 1) topic tags with published or draft children (level 2) tags" do
        tag = create(:topic, :published, children: [create(:topic, :published)])

        expect { TagArchiver.new(tag, content_item_successor).archive }.to raise_error(RuntimeError)
      end

      it "archives the level 2 tag" do
        tag = create(:topic, :published, parent: create(:topic))

        TagArchiver.new(tag, content_item_successor).archive
        tag.reload

        expect(tag.archived?).to be(true)
      end

      it "archives the level 1 tag with archived children" do
        tag = create(:topic, :published, children: [create(:topic, :archived)])

        TagArchiver.new(tag, content_item_successor).archive
        tag.reload

        expect(tag.archived?).to be(true)
      end

      it "creates a redirect to its successor" do
        tag = create(:topic, :published, parent: create(:topic))

        TagArchiver.new(tag, content_item_successor).archive
        redirect = tag.redirect_routes.first

        expect(redirect.from_base_path).to eql tag.base_path
        expect(redirect.to_base_path).to eql content_item_successor.base_path
      end

      it "creates redirects for the suffixes" do
        tag = create(:topic, :published, slug: "bar", parent: create(:topic, slug: "foo"))

        TagArchiver.new(tag, content_item_successor).archive

        expect(tag.redirect_routes.map(&:from_base_path)).to eql([
          "/topic/foo/bar",
          "/topic/foo/bar/latest",
        ])
      end

      it "republishes the content item" do
        tag = create(:topic, :published, parent: create(:topic))

        TagArchiver.new(tag, content_item_successor).archive

        expect(Services.publishing_api).to have_received(:put_content)
      end

      it "calls the email alert updater when archiving level 2 specialist topics" do
        tag = create(:topic, :published, parent: create(:topic))
        expect(email_alert_updater).to receive(:call).with(item: tag, successor: content_item_successor)

        TagArchiver.new(tag, content_item_successor, email_alert_updater).archive
      end

      it "does not call the email alert updater when archiving level 1 specialist topics" do
        tag = create(:topic, :published, children: [create(:topic, :archived)])
        any_successor = create(:mainstream_browse_page)

        expect(email_alert_updater).to receive(:call).with(item: tag, successor: any_successor).never
        TagArchiver.new(tag, any_successor).archive
      end
    end
  end
end
