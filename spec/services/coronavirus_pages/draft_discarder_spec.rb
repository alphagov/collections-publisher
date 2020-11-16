require "rails_helper"

RSpec.describe CoronavirusPages::DraftDiscarder do
  let(:coronavirus_page) { create :coronavirus_page, :landing, state: "draft" }

  before do
    allow(GdsApi.publishing_api).to receive(:lookup_content_ids).and_return({})
  end

  describe "announcements" do
    it "replaces the existing announcement" do
      create(
        :announcement,
        coronavirus_page: coronavirus_page,
        text: "Foo",
      )

      described_class.new(coronavirus_page, payload_from_publishing_api).call
      coronavirus_page.reload

      expect(coronavirus_page.announcements.count).to eq(1)
      expect(coronavirus_page.announcements.first.text).to eq("More rapid COVID-19 tests to be rolled out across England")
      expect(coronavirus_page.announcements.first.position).to eq(1)
    end

    it "removes the announcements if there aren't any announcements in publishing_api" do
      create(:announcement, coronavirus_page: coronavirus_page)

      payload = payload_from_publishing_api
      payload["details"]["announcements"].clear

      described_class.new(coronavirus_page, payload).call
      coronavirus_page.reload

      expect(coronavirus_page.announcements.count).to eq(0)
    end
  end

  it "sets the status to published" do
    described_class.new(coronavirus_page, payload_from_publishing_api).call
    coronavirus_page.reload

    expect(coronavirus_page.state).to eq("published")
  end

  def payload_from_publishing_api
    JSON.parse(File.read(Rails.root.join("spec/fixtures/coronavirus_page_sections.json")))
  end
end
