require "rails_helper"

RSpec.describe CoronavirusPagePresenter do
  include GovukContentSchemaTestHelpers

  let(:content) {
    {
      "title" => "coronavirus",
      "meta_description" => "details about the coronavirus response",
      "sections" => "some sections",
    }
  }

  subject { described_class.new(content) }

  it "presents the payload correctly" do
    presented = subject.payload
    expect(presented).to be_valid_against_schema("coronavirus_landing_page")

    expect(presented).to eq(
      {
        "base_path" => "/coronavirus",
        "title" => "coronavirus",
        "description" => "details about the coronavirus response",
        "document_type" => "coronavirus_landing_page",
        "schema_name" => "coronavirus_landing_page",
        "details" => {
          "sections" => "some sections",
        },
        "links" => {},
        "locale" => "en",
        "rendering_app" => "collections",
        "publishing_app" => "collections-publisher",
        "routes" => [
          { "path" => "/coronavirus", "type" => "exact" },
        ],
      },
    )
  end
end
