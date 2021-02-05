require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Make changes to the Coronavirus live stream URL" do
  include CommonFeatureSteps
  include CoronavirusFeatureSteps
  include GdsApi::TestHelpers::PublishingApi

  before do
    given_i_am_a_coronavirus_editor
    stub_coronavirus_publishing_api
    stub_all_github_requests
    stub_youtube
  end

  scenario "Publish a valid livestream url" do
    when_i_visit_the_coronavirus_index_page
    and_i_select_live_stream
    i_am_able_to_update_draft_content_with_valid_url
    and_i_see_live_stream_is_updated_message
    and_i_can_check_the_preview
    and_i_can_publish_the_url
    and_i_see_a_link_to_the_landing_page
  end

  scenario "Adding an invalid livestream url" do
    when_i_visit_the_coronavirus_index_page
    and_i_select_live_stream
    i_am_able_to_submit_an_invalid_url
    and_i_see_the_error_message
    and_nothing_is_sent_publishing_api
  end
end
