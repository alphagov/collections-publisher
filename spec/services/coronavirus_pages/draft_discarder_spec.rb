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

  describe "sub_sections" do
    it "replaces the existing sub_sections" do
      create(
        :sub_section,
        coronavirus_page: coronavirus_page,
        title: "Foo",
      )

      described_class.new(coronavirus_page, payload_from_publishing_api).call
      coronavirus_page.reload

      expect(coronavirus_page.sub_sections.count).to eq(3)
      expect(coronavirus_page.sub_sections.first.title).to eq("Protect yourself and others from coronavirus")
      expect(coronavirus_page.sub_sections.first.position).to eq(0)
    end

    it "removes the sub_sections if there aren't any sub_sections in publishing_api" do
      create(:sub_section, coronavirus_page: coronavirus_page)

      payload = payload_from_publishing_api
      payload["details"]["sections"].clear

      described_class.new(coronavirus_page, payload).call
      coronavirus_page.reload

      expect(coronavirus_page.sub_sections.count).to eq(0)
    end

    it "creates sub_sections with a position that reflects their order in the content item" do
      described_class.new(coronavirus_page, payload_from_publishing_api).call
      coronavirus_page.reload

      input_order = payload_from_publishing_api["details"]["sections"]
        .pluck("title").each_with_index.to_h.invert

      coronavirus_page.sub_sections.each do |sub_section|
        position = sub_section.position
        expect(input_order[position]).to eq(sub_section.title)
      end
    end

    it "removes any priority-taxons query parameters from the live content" do
      expect(payload_from_publishing_api["details"]["sections"].first["sub_sections"].first["list"].first["url"])
        .to eq("/government/publications/covid-19-stay-at-home-guidance?priority-taxon=774cee22-d896-44c1-a611-e3109cce8eae")

      described_class.new(coronavirus_page, payload_from_publishing_api).call
      coronavirus_page.reload

      expect(coronavirus_page.sub_sections.first.content).to include("/government/publications/covid-19-stay-at-home-guidance")
      expect(coronavirus_page.sub_sections.first.content).not_to include("priority-taxon")
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
