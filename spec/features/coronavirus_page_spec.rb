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
      stub_any_publishing_api_put_intent
    end

    scenario "User views the page" do
      given_there_is_a_coronavirus_page
      when_i_visit_the_coronavirus_index_page
      then_i_see_an_edit_landing_page_link
    end
  end

  describe "Changes made in collections publisher" do
    before do
      given_i_am_a_coronavirus_editor
      stub_coronavirus_publishing_api
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

    scenario "Editing the header section" do
      given_there_is_a_coronavirus_page
      when_i_visit_a_coronavirus_page
      then_i_can_see_a_header_section
      when_i_edit_the_header_section
      then_i_can_see_the_edit_header_form
      when_i_fill_in_the_edit_header_form_with_valid_data
      then_i_see_header_updated_message
    end
  end
end
