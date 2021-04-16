require "rails_helper"

RSpec.describe Coronavirus::Pages::DraftDiscarder do
  let(:page) do
    create(
      :coronavirus_page,
      :landing,
      state: "draft",
      content_id: "774cee22-d896-44c1-a611-e3109cce8eae",
    )
  end

  before do
    allow(GdsApi.publishing_api).to receive(:lookup_content_ids).and_return({})
  end

  describe "announcements" do
    it "replaces the existing announcement" do
      create(:coronavirus_announcement, page: page, title: "Foo")

      stub_publishing_api_has_item(payload_from_publishing_api)

      described_class.new(page).call
      page.reload

      expect(page.announcements.count).to eq(1)
      expect(page.announcements.first.title).to eq("More rapid COVID-19 tests to be rolled out across England")
      expect(page.announcements.first.position).to eq(1)
    end

    it "removes the announcements if there aren't any announcements in publishing_api" do
      create(:coronavirus_announcement, page: page)

      payload = payload_from_publishing_api
      payload["details"]["announcements"].clear

      stub_publishing_api_has_item(payload)

      described_class.new(page).call
      page.reload

      expect(page.announcements.count).to eq(0)
    end
  end

  describe "sub_sections" do
    it "replaces the existing sub_sections" do
      create(:coronavirus_sub_section, page: page, title: "Foo")

      stub_publishing_api_has_item(payload_from_publishing_api)

      described_class.new(page).call
      page.reload

      expect(page.sub_sections.count).to eq(3)
      expect(page.sub_sections.first.title).to eq("Protect yourself and others from coronavirus")
      expect(page.sub_sections.first.position).to eq(0)
      expect(page.sub_sections.first.content).to eq(
        "[Stay at home if you think you have coronavirus (self-isolating)](/government/publications/covid-19-stay-at-home-guidance)",
      )

      expect(page.sub_sections.first.action_link_url).to eq("/bananas")
      expect(page.sub_sections.first.action_link_content).to eq("Bananas")
      expect(page.sub_sections.first.action_link_summary).to eq("Bananas")
    end

    it "removes the sub_sections if there aren't any sub_sections in publishing_api" do
      create(:coronavirus_sub_section, page: page)

      payload = payload_from_publishing_api
      payload["details"]["sections"].clear

      stub_publishing_api_has_item(payload)

      described_class.new(page).call
      page.reload

      expect(page.sub_sections.count).to eq(0)
    end

    it "creates sub_sections with a position that reflects their order in the content item" do
      stub_publishing_api_has_item(payload_from_publishing_api)

      described_class.new(page).call
      page.reload

      input_order = payload_from_publishing_api["details"]["sections"]
        .pluck("title").each_with_index.to_h.invert

      page.sub_sections.each do |sub_section|
        position = sub_section.position
        expect(input_order[position]).to eq(sub_section.title)
      end
    end

    it "removes any priority-taxons query parameters from the live content" do
      expect(payload_from_publishing_api["details"]["sections"].first["sub_sections"].second["list"].first["url"])
        .to eq("/government/publications/covid-19-stay-at-home-guidance?priority-taxon=774cee22-d896-44c1-a611-e3109cce8eae")

      stub_publishing_api_has_item(payload_from_publishing_api)

      described_class.new(page).call
      page.reload

      expect(page.sub_sections.first.content).to include("/government/publications/covid-19-stay-at-home-guidance")
      expect(page.sub_sections.first.content).not_to include("priority-taxon")
    end
  end

  describe "timeline entries" do
    it "replaces the existing timeline entries in the correct position order" do
      create(:coronavirus_timeline_entry, page: page, heading: "Foo")

      stub_publishing_api_has_item(payload_from_publishing_api)

      described_class.new(page).call
      page.timeline_entries.reload

      expect(page.timeline_entries.count).to eq(2)
      expect(page.timeline_entries.second.heading).to eq("5 January")
      expect(page.timeline_entries.second.position).to eq(1)
      expect(page.timeline_entries.first.heading).to eq("4 January")
      expect(page.timeline_entries.first.position).to eq(2)
    end

    it "removes the timeline entries if there isn't a timeline list in Publishing API" do
      create(:coronavirus_timeline_entry, page: page)

      payload = payload_from_publishing_api
      payload["details"]["timeline"]["list"].clear

      stub_publishing_api_has_item(payload)

      described_class.new(page).call
      page.reload

      expect(page.timeline_entries.count).to eq(0)
    end
  end

  it "sets the status to published" do
    stub_publishing_api_has_item(payload_from_publishing_api)

    described_class.new(page).call
    page.reload

    expect(page.state).to eq("published")
  end

  it "doesn't discard the draft if publishing_api doesn't have a live content item" do
    payload = payload_from_publishing_api
    payload["state_history"]["1"] = "draft"

    stub_publishing_api_has_item(payload)

    described_class.new(page).call
    page.reload

    expect(page.state).to eq("draft")
  end

  it "doesn't discard the draft if publishing_api doesn't return a content item" do
    stub_any_publishing_api_call_to_return_not_found

    described_class.new(page).call
    page.reload

    expect(page.state).to eq("draft")
  end

  def payload_from_publishing_api
    JSON.parse(File.read(Rails.root.join("spec/fixtures/coronavirus_page_sections.json")))
  end
end
