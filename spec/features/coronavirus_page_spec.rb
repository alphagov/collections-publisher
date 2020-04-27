require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Publish updates to Coronavirus pages" do
  include CommonFeatureSteps
  include GdsApi::TestHelpers::PublishingApi

  context "Landing page" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_github_request
      stub_any_publishing_api_put_intent
    end

    scenario "User views the page" do
      when_i_visit_the_publish_coronavirus_page
      i_see_a_landing_page_button
      i_see_a_business_page_button
    end

    scenario "User selects landing page" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_landing_page
      i_see_an_update_draft_button
      and_a_preview_button
      and_a_publish_button
    end

    scenario "Updating draft landing page" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_landing_page
      and_i_push_a_new_draft_version
      then_the_content_is_sent_to_publishing_api
      and_i_see_a_draft_updated_message
    end

    scenario "Updating landing draft with invalid content" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_landing_page
      and_i_push_a_new_draft_version_with_invalid_content
      and_i_see_an_alert
    end

    scenario "Publishing landing page" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_landing_page
      and_i_choose_a_major_update
      and_i_publish_the_page
      then_the_page_publishes
      and_i_see_a_page_published_message
    end
  end

  context "Business page" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_github_business_request
      stub_any_publishing_api_put_intent
    end

    scenario "User selects business page" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_business_page
      i_see_an_update_draft_button
      and_a_preview_button
      and_a_publish_button
      and_a_view_live_business_content_button
    end

    scenario "Updating draft business page" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_business_page
      and_i_push_a_new_draft_version
      then_the_business_content_is_sent_to_publishing_api
      and_i_see_a_draft_updated_message
    end

    scenario "Updating business draft with invalid content" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_business_page
      and_i_push_a_new_draft_business_version_with_invalid_content
      and_i_see_an_alert_for_missing_hub_page_keys
    end

    scenario "Publishing business page" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_business_page
      and_i_choose_a_major_update
      and_i_publish_the_page
      then_the_business_page_publishes
      and_i_see_a_page_published_message
    end

    scenario "Unconfigured page" do
      when_i_visit_a_non_existent_page
      then_i_am_redirected_to_the_index_page
      and_i_see_a_message_telling_me_that_the_page_does_not_exist
    end
  end

  context "Live stream updates" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_restclient
    end

    scenario "Add a valid livestream url" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_live_stream
      i_am_able_to_submit_a_valid_url
      the_payload_contains_the_valid_url
      and_i_see_live_stream_is_published_message
      and_i_see_a_link_to_the_landing_page
    end

    scenario "Add an invalid livestream url" do
      when_i_visit_the_publish_coronavirus_page
      and_i_select_live_stream
      i_am_able_to_submit_an_invalid_url
      and_i_see_the_error_message
      and_nothing_is_sent_publishing_api
    end
  end
end
