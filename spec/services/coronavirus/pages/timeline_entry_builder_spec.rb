require "rails_helper"

RSpec.describe Coronavirus::Pages::TimelineEntryBuilder do
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(fixture_path)) }

  let(:page) { create(:coronavirus_page, :landing) }

  before do
    stub_request(:get, Regexp.new(page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
  end

  it "creates new timeline entries from the yaml file in reverse order" do
    described_class.new.create_timeline_entries

    expect(page.timeline_entries.count).to eq(2)

    first_entry = page.timeline_entries.first

    expect(first_entry.heading).to eq(github_entry_list.second["heading"])
    expect(first_entry.content).to eq(github_entry_list.second["paragraph"])
  end

  it "removes existing timeline entries before creating new ones" do
    create(:coronavirus_timeline_entry, page: page)
    create(:coronavirus_timeline_entry, page: page)
    create(:coronavirus_timeline_entry, page: page)

    described_class.new.create_timeline_entries

    expect(page.timeline_entries.count).to eq(2)
  end

  it "doesn't remove existing timeline entries if the YAML file is empty" do
    described_class.new.create_timeline_entries

    github_content = YAML.safe_load(File.read(fixture_path))
    github_content.dig("content", "timeline", "list").clear

    stub_request(:get, Regexp.new(page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)

    described_class.new.create_timeline_entries

    expect(page.timeline_entries.count).to be(2)
  end

  it "keeps the timeline entries in the right order" do
    new_data = { "heading" => "heading", "paragraph" => "paragraph" }

    github_content = YAML.safe_load(File.read(fixture_path))
    github_content.dig("content", "timeline", "list").unshift(new_data)

    stub_request(:get, Regexp.new(page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)

    described_class.new.create_timeline_entries

    expect(page.timeline_entries.last.heading).to eq("heading")
    expect(page.timeline_entries.last.position).to eq(1)
  end

  def github_entry_list
    github_content.dig("content", "timeline", "list")
  end
end
