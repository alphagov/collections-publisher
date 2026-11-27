require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe MainstreamBrowsePageArchivalForm do
  include GdsApi::TestHelpers::ContentStore

  describe "#browse_pages" do
    it "returns published mainstream browse pages that can be successors" do
      create(:mainstream_browse_page, :draft)
      create(:mainstream_browse_page, :archived)
      published = create(:mainstream_browse_page, :published)
      mainstream_browse_page_self = create(:mainstream_browse_page, :published)

      mainstream_browse_pages = MainstreamBrowsePageArchivalForm.new(tag: mainstream_browse_page_self).browse_pages

      expect(mainstream_browse_pages).to eql([published])
    end
  end

  describe "#grouped_browse_pages" do
    it "groups published pages by their top level page, excluding the page being archived" do
      parent = create(:mainstream_browse_page, :published, title: "Benefits")
      child = create(:mainstream_browse_page, :published, title: "Disability", parent:)
      archived_page = create(:mainstream_browse_page, :published, title: "Old page", parent:)
      create(:mainstream_browse_page, :draft, title: "Draft page", parent:)

      form = MainstreamBrowsePageArchivalForm.new(tag: archived_page, successor: child.id.to_s)

      expect(form.grouped_browse_pages).to eql([
        ["Benefits",
         [
           { text: "Benefits", value: parent.id, selected: false },
           { text: "Disability", value: child.id, selected: true },
         ]],
      ])
    end
  end

  def level_two_page(state = :published)
    create(:mainstream_browse_page, state, parent: create(:mainstream_browse_page, :published))
  end

  describe "#redirect_type" do
    it "is not valid if no redirect type is chosen" do
      form = MainstreamBrowsePageArchivalForm.new

      expect(form.valid?).to eql(false)
      expect(form.errors[:redirect_type]).to be_present
    end

    it "is not valid if a browse page redirect is chosen without picking a page" do
      form = MainstreamBrowsePageArchivalForm.new(tag: level_two_page, redirect_type: "browse_page", successor: "")

      expect(form.valid?).to eql(false)
      expect(form.errors[:successor]).to be_present
    end

    it "is not valid if the chosen browse page is the page being archived" do
      tag = level_two_page
      form = MainstreamBrowsePageArchivalForm.new(tag:, redirect_type: "browse_page", successor: tag.id.to_s)

      expect(form.valid?).to eql(false)
      expect(form.errors[:successor]).to be_present
    end

    it "is valid if a published browse page is chosen" do
      successor = create(:mainstream_browse_page, :published)
      form = MainstreamBrowsePageArchivalForm.new(tag: level_two_page, redirect_type: "browse_page", successor: successor.id.to_s)

      expect(form.valid?).to eql(true)
    end
  end

  describe "#valid?" do
    before { stub_content_store_has_item("/existing-item") }

    it "is not valid for an archived page" do
      form = MainstreamBrowsePageArchivalForm.new(tag: level_two_page(:archived), redirect_type: "path", successor_path: "/existing-item")

      expect(form.valid?).to eql(false)
      expect(form.errors[:base]).to eql(["This mainstream browse page cannot be archived or removed"])
    end

    it "is not valid for a published top level page" do
      form = MainstreamBrowsePageArchivalForm.new(tag: create(:mainstream_browse_page, :published), redirect_type: "path", successor_path: "/existing-item")

      expect(form.valid?).to eql(false)
      expect(form.errors[:base]).to be_present
    end

    it "is not valid for a draft top level page" do
      form = MainstreamBrowsePageArchivalForm.new(tag: create(:mainstream_browse_page, :draft))

      expect(form.valid?).to eql(false)
      expect(form.errors[:base]).to be_present
    end

    it "is valid for a draft second level page without a redirect" do
      form = MainstreamBrowsePageArchivalForm.new(tag: level_two_page(:draft))

      expect(form.valid?).to eql(true)
    end
  end

  describe "#successor_path" do
    it "is not valid if blank" do
      form = MainstreamBrowsePageArchivalForm.new(redirect_type: "path", successor_path: "")

      expect(form.valid?).to eql(false)
      expect(form.errors[:successor_path]).to eql(["Enter a page URL path"])
    end

    it "is not valid if the URL returns a 404 status code" do
      stub_content_store_does_not_have_item("/not-here")

      form = MainstreamBrowsePageArchivalForm.new(redirect_type: "path", successor_path: "/not-here")

      expect(form.valid?).to eql(false)
    end

    it "is not valid if its not really a URL" do
      form = MainstreamBrowsePageArchivalForm.new(redirect_type: "path", successor_path: "/i-Am Not A URL")

      expect(form.valid?).to eql(false)
    end

    it "is not valid if it does not start with a slash" do
      form = MainstreamBrowsePageArchivalForm.new(redirect_type: "path", successor_path: "am-not-a-url")

      expect(form.valid?).to eql(false)
    end

    it "is valid if the URL returns 200" do
      stub_content_store_has_item("/existing-item")

      form = MainstreamBrowsePageArchivalForm.new(redirect_type: "path", successor_path: "/existing-item")

      expect(form.valid?).to eql(true)
    end
  end
end
