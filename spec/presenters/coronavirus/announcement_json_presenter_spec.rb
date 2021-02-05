require "rails_helper"

RSpec.describe Coronavirus::AnnouncementJsonPresenter do
  include CoronavirusHelpers

  let!(:announcement) { create :coronavirus_announcement }

  before do
    stub_coronavirus_landing_page_content(announcement.page)
  end

  describe "#output" do
    it "returns presented announcement" do
      expected = {
        "text" => announcement.title.to_s,
        "href" => announcement.path.to_s,
        "published_text" => announcement.published_at.strftime("Published %-d %B %Y"),
      }

      expect(described_class.new(announcement).output).to eq(expected)
    end
  end
end
