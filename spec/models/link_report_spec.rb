require "rails_helper"
require "gds_api/test_helpers/link_checker_api"

RSpec.describe LinkReport, type: :model do
  include GdsApi::TestHelpers::LinkCheckerApi
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  describe ".create_record" do
    context "when the step content has links" do
      it "should create a record with the right batch_id" do
        step = create(:step)
        link_report = create(:link_report, step: step)
        stub_link_checker_api_create_batch(
          uris: [
            "http://example.com/good",
            "https://www.gov.uk/good/stuff",
            "https://www.gov.uk/also/good/stuff",
            "https://www.gov.uk/not/as/great",
          ],
          webhook_uri: "https://collections-publisher.test.gov.uk/link_report",
          checked_within: 0,
        )
        link_report.create_record
        expect(LinkReport.find_by(batch_id: 0)).to be
      end
    end

    context "when the step content does not have links" do
      it "should return delete itself" do
        step = create(:step, contents: "Lorem ipsum")
        link_report = create(:link_report, step: step)
        link_report.create_record
        expect(LinkReport.find_by(batch_id: 0)).to be_nil
      end
    end
  end
end
