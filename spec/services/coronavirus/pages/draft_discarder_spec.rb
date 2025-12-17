require "rails_helper"

RSpec.describe Coronavirus::Pages::DraftDiscarder do
  let(:page) do
    create(
      :coronavirus_page,
      state: "draft",
      content_id: "774cee22-d896-44c1-a611-e3109cce8eae",
    )
  end

  before do
    allow(GdsApi.publishing_api).to receive(:lookup_content_ids).and_return({})
  end

  describe "sub_sections" do
    it "replaces the existing sub_sections" do
      create(:coronavirus_sub_section, page:, title: "Foo")

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
      create(:coronavirus_sub_section, page:)

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

  it "sets the status to published" do
    stub_publishing_api_has_item(payload_from_publishing_api)

    described_class.new(page).call
    page.reload

    expect(page.state).to eq("published")
  end

  it "doesn't discard the draft if publishing_api doesn't have a live content item" do
    stub_publishing_api_does_not_have_item(page.content_id)

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
