require 'rails_helper'
require 'gds_api/test_helpers/link_checker_api'

RSpec.describe LinkReport do
  include GdsApi::TestHelpers::LinkCheckerApi
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end
  describe '.batch_links' do
    context 'when there are links' do
      it 'should return the links in an array' do
        step = create(:step)
        link_report = create(:link_report, step: step)
        expect(link_report.batch_links).to eql [
          'https://www.gov.uk/good/stuff',
          "https://www.gov.uk/also/good/stuff",
          "https://www.gov.uk/not/as/great",
          "http://example.com/good"
        ]
      end
    end
  end

  describe '.create_batch' do
    it 'should create a new LinkReport and save it' do
      link_checker_api_create_batch(
        uris: [
          'https://www.gov.uk/good/stuff',
          "https://www.gov.uk/also/good/stuff",
          "https://www.gov.uk/not/as/great",
          "http://example.com/good"
        ],
        webhook_uri: "https://collections-publisher.test.gov.uk/link_report"
      )
      step = create(:step)
      link_report = create(:link_report, step: step)
      link_report.create_batch
      expect(LinkReport.find_by(batch_id: 0)).to_not be_nil
    end
  end
end
