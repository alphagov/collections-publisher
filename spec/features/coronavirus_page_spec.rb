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
      stub_github_request
      stub_any_publishing_api_put_intent
    end

    scenario "User views the page" do
      when_i_visit_the_coronavirus_index_page
      i_see_a_publish_landing_page_link
    end
  end

  describe "Changes made in collections publisher" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_github_request
      stub_any_publishing_api_put_intent
    end

    scenario "Publishing landing page" do
      given_there_is_a_coronavirus_page
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
      given_there_is_a_published_coronavirus_page
      stub_discard_coronavirus_page_no_draft
      when_i_visit_a_coronavirus_page
      and_i_see_state_is_published
      and_i_discard_my_changes
      i_see_error_message_no_changes_to_discard
      and_i_see_state_is_published
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
      given_there_is_a_coronavirus_page
      when_i_visit_a_coronavirus_page
      and_i_add_a_new_timeline_entry
      then_i_see_the_timeline_entry_form
      when_i_fill_in_the_timeline_entry_form_with_valid_data
      then_i_see_a_new_timeline_entry_has_been_created
    end

    scenario "Editing timeline entries" do
      given_there_is_a_coronavirus_page_with_timeline_entries
      when_i_visit_a_coronavirus_page
      and_i_change_a_timeline_entry
      then_i_see_the_timeline_entry_form
      and_i_see_the_existing_timeline_entry_data
      when_i_fill_in_the_timeline_entry_form_with_valid_data
      then_i_see_the_timeline_entry_has_been_updated
    end

    scenario "Reordering timeline entries", js: true do
      given_there_is_a_coronavirus_page_with_timeline_entries
      when_i_visit_the_reorder_timeline_entries_page
      then_i_see_the_timeline_entries_in_order
      when_i_move_timeline_entry_one_down
      then_i_see_timeline_entries_updated_message
      and_i_see_the_timeline_entries_have_changed_order
    end

    scenario "Viewing timeline entries" do
      given_there_is_a_coronavirus_page_with_timeline_entries
      when_i_visit_a_coronavirus_page
      then_i_can_see_a_timeline_entries_section
      and_i_can_see_existing_timeline_entries
    end

    scenario "Deleting timeline entries", js: true do
      given_there_is_a_coronavirus_page_with_timeline_entries
      when_i_visit_a_coronavirus_page
      then_i_can_see_a_timeline_entries_section
      when_i_delete_a_timeline_entry
      then_i_can_see_the_timeline_entry_has_been_deleted
    end

    scenario "Editing the header section" do
      given_i_can_access_unreleased_features
      given_there_is_a_coronavirus_page
      when_i_visit_a_coronavirus_page
      then_i_can_see_a_header_section
      when_i_edit_the_header_section
      then_i_can_see_the_edit_header_form
      when_i_fill_in_the_edit_header_form_with_valid_data
      then_i_see_header_updated_message
    end
  end

  describe "Changes made in github" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
      stub_github_request
      stub_any_publishing_api_put_intent
    end

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
      and_i_remain_on_the_coronavirus_github_changes_page
      then_the_page_publishes
      and_i_see_github_changes_published_message
    end
  end
end
