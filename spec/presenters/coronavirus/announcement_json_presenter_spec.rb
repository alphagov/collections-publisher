require "rails_helper"

RSpec.describe Coronavirus::AnnouncementJsonPresenter do
  include CoronavirusHelpers

  describe "#output" do
    it "returns presented announcement" do
      announcement = build(:coronavirus_announcement)
      stub_coronavirus_landing_page_content(announcement.page)

      expected = {
        "text" => announcement.title,
        "href" => announcement.url,
        "published_text" => announcement.published_at.strftime("Published %-d %B %Y"),
      }

      expect(described_class.new(announcement).output).to eq(expected)
    end

    it "doesn't include published text for an announcement without a published_at date" do
      announcement = build(:coronavirus_announcement, published_at: nil)
      stub_coronavirus_landing_page_content(announcement.page)

      expect(described_class.new(announcement).output)
        .to eq("text" => announcement.title, "href" => announcement.url)
    end
  end
end
