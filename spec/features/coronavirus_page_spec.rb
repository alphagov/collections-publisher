require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Publish updates to Coronavirus pages" do
  include CommonFeatureSteps
  include GdsApi::TestHelpers::PublishingApi

  describe "Index page" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_all_github_requests
      stub_any_publishing_api_put_intent
      stub_youtube
    end

    scenario "User views the page" do
      when_i_visit_the_coronavirus_index_page
      i_see_a_publish_landing_page_link
      i_see_a_publish_business_page_link
    end
  end

  describe "Changes made in collections publisher" do
    before do
      given_i_am_an_unreleased_feature_editor
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_all_github_requests
      stub_any_publishing_api_put_intent
      given_a_livestream_exists
    end

    scenario "Publishing landing page" do
      when_i_visit_a_coronavirus_page
      and_i_publish_the_page
      then_the_page_publishes_a_minor_update
      and_i_remain_on_the_coronavirus_page
      and_i_see_a_page_published_message
      and_i_see_state_is_published
    end

    scenario "Reordering sections", js: true do
      set_up_basic_sub_sections
      when_i_visit_the_reorder_page
      i_see_subsection_one_in_position_one
      and_i_move_section_one_down
      then_the_reordered_subsections_are_sent_to_publishing_api
      then_i_see_section_updated_message
      and_i_see_state_is_draft
    end
  end

  describe "Changes made in github" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_all_github_requests
      stub_any_publishing_api_put_intent
      given_a_livestream_exists
    end

    context "Landing page" do
      scenario "User selects landing page" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_landing_page
        i_see_an_update_draft_button
        and_a_preview_button
        and_a_publish_button
      end

      scenario "Updating draft landing page" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_landing_page
        and_i_push_a_new_draft_version
        then_the_content_is_sent_to_publishing_api
        and_i_see_a_draft_updated_message
      end

      scenario "Updating landing draft with invalid content" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_landing_page
        and_i_push_a_new_draft_version_with_invalid_content
        and_i_see_an_alert
      end

      scenario "Publishing landing page" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_landing_page
        and_i_choose_a_major_update
        and_i_publish_the_page
        and_i_remain_on_the_coronavirus_prepare_page
        then_the_page_publishes
        and_i_see_a_page_published_message
      end
    end

    context "Business page" do
      before do
        given_i_am_a_coronavirus_editor
        stub_coronavirus_publishing_api
        stub_all_github_requests
        stub_any_publishing_api_put_intent
        stub_youtube
      end

      scenario "User selects business page" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_business_page
        i_see_an_update_draft_button
        and_a_preview_button
        and_a_publish_button
        and_a_view_live_business_content_button
      end

      scenario "Updating draft business page" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_business_page
        stub_github_business_request
        and_i_push_a_new_draft_version
        then_the_business_content_is_sent_to_publishing_api
        and_i_see_a_draft_updated_message
      end

      scenario "Updating business draft with invalid content" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_business_page
        and_i_push_a_new_draft_business_version_with_invalid_content
        and_i_see_an_alert_for_missing_hub_page_keys
      end

      scenario "Publishing business page" do
        when_i_visit_the_coronavirus_index_page
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
  end
end
