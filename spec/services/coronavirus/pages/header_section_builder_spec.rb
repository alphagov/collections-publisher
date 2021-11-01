require "rails_helper"

RSpec.describe Coronavirus::Pages::HeaderSectionBuilder do
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(fixture_path)) }
  let(:coronavirus_page) { create(:coronavirus_page) }

  before do
    stub_request(:get, Regexp.new(coronavirus_page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
  end

  it "creates new header entries" do
    described_class.new.create_header
    coronavirus_page.reload

    github_header_section = github_content.dig("content", "header_section")

    expect(coronavirus_page.header_title).to eq(github_header_section["title"])
    expect(coronavirus_page.header_body).to eq(github_header_section["intro"])
    expect(coronavirus_page.header_link_url).to eq(github_header_section["link"]["href"])
    expect(coronavirus_page.header_link_pre_wrap_text).to eq(github_header_section["link"]["link_text"])
    expect(coronavirus_page.header_link_post_wrap_text).to eq(github_header_section["link"]["link_nowrap_text"])
  end

  it "does not update existing header entries if the YAML file is empty" do
    coronavirus_page = create(
      :coronavirus_page,
      header_title: "Existing title",
      header_body: "Existing body",
      header_link_url: "/path",
      header_link_pre_wrap_text: "Existing link text",
      header_link_post_wrap_text: "Existing link wrap text",
    )

    github_content.dig("content", "header_section").clear

    described_class.new.create_header
    coronavirus_page.reload

    expect(coronavirus_page.header_title).to eq("Existing title")
    expect(coronavirus_page.header_body).to eq("Existing body")
  end
end
