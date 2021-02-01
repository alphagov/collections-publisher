require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Publish updates to Coronavirus pages" do
  include CommonFeatureSteps
  include CoronavirusFeatureSteps
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

    scenario "Reordering sections of a published page", js: true do
      set_up_basic_sub_sections
      stub_discard_subsection_changes
      when_i_visit_the_reorder_page
      i_see_subsection_one_in_position_one
      and_i_move_section_one_down
      then_the_reordered_subsections_are_sent_to_publishing_api
      then_i_see_section_updated_message
      and_i_see_state_is_draft
      and_i_discard_my_changes
      and_i_see_state_is_published
    end

    scenario "Discarding changes" do
      stub_live_sub_sections_content_request(coronavirus_content_id)
      stub_discard_coronavirus_page_no_draft
      when_i_visit_a_coronavirus_page
      and_i_see_state_is_published
      and_i_discard_my_changes
      i_see_error_message_no_changes_to_discard
      and_i_see_state_is_published
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

      scenario "Viewing announcements" do
        given_there_is_coronavirus_page_with_announcements
        when_i_visit_a_coronavirus_page
        then_i_can_see_an_announcements_section
        and_i_can_see_existing_announcements
      end

      scenario "Adding announcements" do
        given_there_is_coronavirus_page_with_announcements
        when_i_visit_a_coronavirus_page
        then_i_can_see_an_announcements_section
        and_i_add_a_new_announcement
        then_i_see_the_create_announcement_form
        when_i_fill_in_the_announcement_form_with_valid_data
        then_i_can_see_a_new_announcement_has_been_created
      end

      scenario "Editing announcements" do
        given_there_is_coronavirus_page_with_announcements
        when_i_visit_a_coronavirus_page
        then_i_can_see_an_announcements_section
        when_i_can_click_change_for_an_announcement
        then_i_see_the_edit_announcement_form
        when_i_can_edit_the_announcement_form_with_valid_data
        then_i_can_see_that_the_announcement_has_been_updated
      end

      scenario "Deleting announcements", js: true do
        given_there_is_coronavirus_page_with_announcements
        when_i_visit_a_coronavirus_page
        then_i_can_see_an_announcements_section
        when_i_delete_an_announcement
        then_i_can_see_an_announcement_has_been_deleted
      end

      scenario "Reordering announcements", js: true do
        given_there_is_coronavirus_page_with_announcements
        when_i_visit_the_reorder_announcements_page
        then_i_see_the_announcements_in_order
        when_i_move_announcement_one_down
        then_i_see_announcement_updated_message
        and_i_see_the_announcements_have_changed_order
      end

      scenario "Adding timeline entries" do
        given_i_can_access_unreleased_features
        given_there_is_a_coronavirus_page
        when_i_visit_a_coronavirus_page
        and_i_add_a_new_timeline_entry
        then_i_see_the_timeline_entry_form
        when_i_fill_in_the_timeline_entry_form_with_valid_data
        then_i_see_a_new_timeline_entry_has_been_created
      end

      scenario "Editing timeline entries" do
        given_i_can_access_unreleased_features
        given_there_is_a_coronavirus_page_with_timeline_entries
        when_i_visit_a_coronavirus_page
        and_i_change_a_timeline_entry
        then_i_see_the_timeline_entry_form
        and_i_see_the_existing_timeline_entry_data
        when_i_fill_in_the_timeline_entry_form_with_valid_data
        then_i_see_the_timeline_entry_has_been_updated
      end

      scenario "Reordering timeline entries", js: true do
        given_i_can_access_unreleased_features
        given_there_is_a_coronavirus_page_with_timeline_entries
        when_i_visit_the_reorder_timeline_entries_page
        then_i_see_the_timeline_entries_in_order
        when_i_move_timeline_entry_one_down
        then_i_see_timeline_entries_updated_message
        and_i_see_the_timeline_entries_have_changed_order
      end

      scenario "Viewing timeline entries" do
        given_i_can_access_unreleased_features
        given_there_is_a_coronavirus_page_with_timeline_entries
        when_i_visit_a_coronavirus_page
        then_i_can_see_a_timeline_entries_section
        and_i_can_see_existing_timeline_entries
      end

      scenario "Timeline entries should only be visable on the landing page" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_business_page
        then_i_cannot_see_a_timeline_entries_section
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

      scenario "Viewing announcements" do
        when_i_visit_the_coronavirus_index_page
        and_i_select_business_page
        then_i_cannot_see_an_announcements_section
      end
    end
  end
end
