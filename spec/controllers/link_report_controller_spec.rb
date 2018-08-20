require 'rails_helper'
require 'gds_api/test_helpers/link_checker_api'

RSpec.describe LinkReportController do
  include GdsApi::TestHelpers::LinkCheckerApi
  describe '.update' do
    it 'should update an existing LinkReport' do
      time = Time.now
      create(:link_report, batch_id: 1234, completed: nil)
      post :update, params: link_checker_api_batch_report_hash(id: 1234, completed_at: time)
      expect(LinkReport.find_by(batch_id: 1234).completed).to be_within(1.second).of time
    end
    context "when the batch_id doesn't exist" do
      it 'should fail gracefully' do
        time = Time.now
        expect { post :update, params: link_checker_api_batch_report_hash(id: 1234, completed_at: time) }.to_not raise_error
      end
    end
  end
end
