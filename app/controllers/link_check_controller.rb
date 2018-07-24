require "gds_api/link_checker_api"

class LinkCheckController < ApplicationController
    # @base_api_url = Plek.find("link-checker-api")
    # @api = GdsApi::LinkCheckerApi.new(@base_api_url)

    def record_batch
        # @api.get_batch(find_batch_id)
    end

    private
    # gets the most recent batch id for the step by step the user is on
    def find_batch_id
        1234
    end
end