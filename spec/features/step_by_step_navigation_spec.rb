require "rails_helper"

RSpec.feature "Managing step by step navigation" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  context "Given I'm a GDS Editor" do
    before do
      given_i_am_a_gds_editor
      setup_publishing_api
    end

    scenario "User configures navigation" do
      given_there_is_a_step_by_step_page_with_navigation_rules
      when_i_visit_the_step_by_step_page
      and_i_click_the_sidebar_settings_link
      then_i_should_be_on_the_navigation_rules_page
      and_i_should_see_all_pages_included_in_navigation
      and_when_i_set_some_navigation_preferences
      then_i_can_see_a_success_message "Your navigation choices have been saved."
      and_i_should_be_on_the_step_by_step_page
      and_when_i_visit_the_navigation_steps_page_again
      then_i_should_see_my_selected_preferences
    end
  end

  def then_i_should_be_on_the_navigation_rules_page
    expect(current_url).to end_with step_by_step_page_navigation_rules_path(@step_by_step_page)
  end

  def and_i_should_see_all_pages_included_in_navigation
    expect(page).to have_css(".govuk-caption-l", text: "Sidebar settings")
    expect(page).to have_css("h1", text: @step_by_step_page.title)

    expect(page).to have_link("Also good stuff", href: "https://draft-origin.test.gov.uk/also/good/stuff")
    checked = page.all(:css, "option[value=always]", &:selected?)
    expect(checked.count).to eq @step_by_step_page.navigation_rules.count
  end

  def and_when_i_set_some_navigation_preferences
    select("Never show navigation", match: :first)

    allow(StepByStepDraftUpdateWorker).to receive(:perform_async)
    click_on "Save"
  end

  def and_i_click_the_sidebar_settings_link
    click_on("Change Sidebar settings")
  end

  alias_method :and_when_i_visit_the_navigation_steps_page_again, :and_i_click_the_sidebar_settings_link

  def then_i_should_see_my_selected_preferences
    expect(page.all(:select)[0].value).to eq("never")
    expect(page.all(:select)[1].value).to eq("always")
  end
end
