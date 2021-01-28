require "rails_helper"

RSpec.describe CoronavirusPages::DraftUpdater do
  include CoronavirusFeatureSteps

  let(:coronavirus_page) { create :coronavirus_page }
  let(:content_builder) { CoronavirusPages::ContentBuilder.new(coronavirus_page) }
  let(:payload) { CoronavirusPagePresenter.new(content_builder.data, coronavirus_page.base_path).payload }
  let(:github_fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(github_fixture_path)) }

  subject { described_class.new(coronavirus_page) }

  before do
    stub_coronavirus_publishing_api
    stub_request(:get, Regexp.new(coronavirus_page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
  end

  it "#payload" do
    expect(subject.payload).to eq payload
  end
end
