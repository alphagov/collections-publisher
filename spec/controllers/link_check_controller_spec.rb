require 'rails_helper'
require 'gds_api/test_helpers/link_checker_api'

RSpec.describe LinkCheckController, type: :controller do
    include GdsApi::TestHelpers::LinkCheckerApi
    
    describe 'GET #batch' do

        it 'receives the batch report for the passed id and saves it' do
            get :record_batch            
            # create a fake "in progress" request
            test_batch = link_checker_api_get_batch(id: 1234, status: :in_progress)
            # call it from the controller
            # check response
            assert_equal :in_progress, test.status
        end

        # create a "complete" request
    end
end