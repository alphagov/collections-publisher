require "rails_helper"

RSpec.describe CoronavirusPages::AnnouncementsBuilder do
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(fixture_path)) }

  let(:coronavirus_page) { create(:coronavirus_page, :landing) }

  before do
    stub_request(:get, Regexp.new(coronavirus_page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
  end

  it "creates new announcements from the yaml file" do
    described_class.new.create_announcements

    expect(coronavirus_page.announcements.count).to eq(3)

    first_announcement = coronavirus_page.announcements.first

    expect(first_announcement.text).to eq(github_announcement["text"])
    expect(first_announcement.href).to eq(github_announcement["href"])
    expect(first_announcement.published_at).to eq(Date.parse(github_announcement["published_text"]))
  end

  def github_announcement
    github_content["content"]["announcements"].first
  end
end
