require "rails_helper"

RSpec.describe AnnouncementJsonPresenter do
  let!(:announcement) { create :announcement }

  before do
    setup_github_data
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

  def setup_github_data
    raw_content = File.read(Rails.root.join("spec/fixtures/coronavirus_landing_page.yml"))
    stub_request(:get, /#{announcement.coronavirus_page.raw_content_url}\?cache-bust=\d+/)
      .to_return(status: 200, body: raw_content)
  end
end
