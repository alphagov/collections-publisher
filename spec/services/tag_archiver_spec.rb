require "rails_helper"

RSpec.describe TagArchiver do
  describe "#archive" do
    let(:email_alert_api) { instance_double(GdsApi::EmailAlertApi) }

    before do
      stub_any_publishing_api_call

      allow(Services.publishing_api).to receive(:put_content)

      allow(Services).to receive(:email_alert_api).and_return(email_alert_api)
      allow(email_alert_api).to receive(:bulk_unsubscribe)
      allow(email_alert_api).to receive(:find_subscriber_list).and_return(
        { "subscriber_list" => { "slug" => "subscriber-list-slug" } },
      )
    end

    it "won't archive parent (level 1) mainstream_browse_page tags" do
      tag = create(:mainstream_browse_page, :published)

      expect { TagArchiver.new(tag, build(:mainstream_browse_page)).archive }.to raise_error(RuntimeError)
    end

    it "won't archive parent (level 1) topic tags with published or draft children (level 2) tags" do
      tag = create(:topic, :published, children: [create(:topic, :published)])

      expect { TagArchiver.new(tag, build(:topic)).archive }.to raise_error(RuntimeError)
    end

    it "archives the level 2 tag" do
      tag = create(:topic, :published, parent: create(:topic))

      TagArchiver.new(tag, build(:topic)).archive
      tag.reload

      expect(tag.archived?).to be(true)
    end

    it "archives the level 1 tag with archived children" do
      tag = create(:topic, :published, children: [create(:topic, :archived)])

      TagArchiver.new(tag, build(:topic)).archive
      tag.reload

      expect(tag.archived?).to be(true)
    end

    it "creates a redirect to its successor" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = create(:topic)

      TagArchiver.new(tag, successor).archive
      redirect = tag.redirect_routes.first

      expect(redirect.from_base_path).to eql tag.base_path
      expect(redirect.to_base_path).to eql successor.base_path
    end

    it "creates a redirect to its non-topic successor" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = OpenStruct.new(base_path: "www.gov.uk/successor", subroutes: [])

      TagArchiver.new(tag, successor).archive
      redirect = tag.redirect_routes.first

      expect(redirect.from_base_path).to eql tag.base_path
      expect(redirect.to_base_path).to eql successor.base_path
    end

    it "creates redirects for the suffixes" do
      tag = create(:topic, :published, slug: "bar", parent: create(:topic, slug: "foo"))
      successor = create(:topic)

      TagArchiver.new(tag, successor).archive

      expect(tag.redirect_routes.map(&:from_base_path)).to eql([
        "/topic/foo/bar",
        "/topic/foo/bar/latest",
      ])
    end

    it "redirects to the base path when the successor is a parent topic" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = create(:topic, slug: "foo")

      TagArchiver.new(tag, successor).archive

      expect(tag.redirect_routes.map(&:to_base_path)).to eql([
        "/topic/foo",
        "/topic/foo",
      ])
    end

    it "redirects to the suffixes when the successor is a child topic" do
      tag = create(:topic, :published, parent: create(:topic))
      successor = create(:topic, slug: "bar", parent: create(:topic, slug: "foo"))

      TagArchiver.new(tag, successor).archive

      expect(tag.redirect_routes.map(&:to_base_path)).to eql([
        "/topic/foo/bar",
        "/topic/foo/bar/latest",
      ])
    end

    it "republishes the content item" do
      tag = create(:topic, :published, parent: create(:topic))

      TagArchiver.new(tag, build(:topic)).archive

      expect(Services.publishing_api).to have_received(:put_content)
    end

    it "unsubscribes from email alerts for the specialist topic (level 2)" do
      tag = create(:topic, :published, parent: create(:topic, slug: "mot"),
                                       slug: "provide-mot-training",
                                       title: "Provide MOT training")
      successor = OpenStruct.new(base_path: "/guidance/become-an-mot-training-provider", subroutes: [])
      expected_email_body = <<~BODY
        This topic has been archived. You will not get any more emails about it.

        You can find more information about this topic at [#{Plek.website_root}/guidance/become-an-mot-training-provider](#{Plek.website_root}/guidance/become-an-mot-training-provider).
      BODY

      TagArchiver.new(tag, successor).archive

      expect(Services.email_alert_api).to have_received(:bulk_unsubscribe).with(
        hash_including(
          slug: "subscriber-list-slug",
          body: expected_email_body,
        ),
      )
    end

    it "doesn't attempt to unsubscribe from email alerts when mainstream browse page is archived" do
      tag = create(:mainstream_browse_page, :published, parent: create(:mainstream_browse_page))

      TagArchiver.new(tag, build(:mainstream_browse_page)).archive

      expect(Services.email_alert_api).to_not have_received(:bulk_unsubscribe)
    end

    it "doesn't attempt to unsubscribe from email alerts when level one topic is archived" do
      tag = create(:topic, :published, children: [create(:topic, :archived)])

      TagArchiver.new(tag, build(:mainstream_browse_page)).archive

      expect(Services.email_alert_api).to_not have_received(:bulk_unsubscribe)
    end

    it "doesn't have side effects when a API call fails" do
      tag = create(:topic, :published, parent: create(:topic))

      expect(Services.publishing_api).to receive(:put_content).and_raise("publishing API call failed")
      expect { TagArchiver.new(tag, build(:topic)).archive }.to raise_error("publishing API call failed")
      tag.reload

      expect(tag.archived?).to be(false)
      expect(tag.redirect_routes.size).to be(0)
    end
  end
end
