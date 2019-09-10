require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "View step by step pages index and filter results" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps
  include GdsApi::TestHelpers::PublishingApi

  before do
    given_I_am_a_GDS_editor
    setup_publishing_api
    stub_default_publishing_api_put_intent
  end

  scenario "User visits the index page" do
    given_there_is_a_step_by_step_page
    when_I_visit_the_step_by_step_pages_index
    then_I_see_the_step_by_step_page
  end

  scenario "User filters results on index page" do
    given_there_are_step_by_step_pages
    when_I_visit_the_step_by_step_pages_index
    and_I_filter_by_title_and_status
    then_I_should_see_a_filtered_list_of_step_by_steps
  end

  def then_I_see_the_step_by_step_page
    expect(page).to have_content("How to be amazing")
  end

  def and_I_filter_by_title_and_status
    fill_in "title_or_url", with: "step nav"
    select "Draft", from: "status"
    click_on "Filter"
  end

  def then_I_should_see_a_filtered_list_of_step_by_steps
    within(".govuk-table__body") do
      expect(page).to have_xpath(".//tr", :count => 1)
      expect(page).to have_content("A draft step nav")
      expect(page).to_not have_content("A published step nav")
    end
  end
end
