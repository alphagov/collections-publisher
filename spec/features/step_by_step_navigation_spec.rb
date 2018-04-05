require "rails_helper"

RSpec.feature "Managing step by step navigation" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  context "Given I'm a GDS Editor" do
    before do
      given_I_am_a_GDS_editor
      setup_publishing_api
    end

    scenario "User configures navigation" do
      given_there_is_a_step_by_step_page_with_steps
      and_I_visit_the_navigation_rules_page
      and_I_see_all_pages_included_in_navigation
      and_I_set_some_navigation_preferences
      then_I_see_the_step_by_step_page
      then_I_visit_the_navigation_steps_page_again
      and_I_see_my_selected_preferences
    end
  end

  def and_I_visit_the_navigation_rules_page
    visit step_by_step_page_navigation_rules_path(@step_by_step_page)
  end

  def and_I_see_all_pages_included_in_navigation
    expect(page).to have_css("h1 small", "Choose on-page side navigation")
    expect(page).to have_css("h1", @step_by_step_page.title)

    expect(page).to have_link("Also good stuff", href: "https://draft-origin.test.gov.uk/also/good/stuff")

    checked = page.all(:css, "input[type=checkbox]") { |check| check.checked? }
    expect(checked.count).to eq @step_by_step_page.navigation_rules.count
  end

  def and_I_set_some_navigation_preferences
    uncheck("Show this navigation", match: :first)

    allow(StepByStepDraftUpdateWorker).to receive(:perform_async)
    click_on "Save"
  end

  def then_I_see_the_step_by_step_page
    expect(page).to have_content("Your navigation choices have been saved")
    expect(page).to have_link("Choose navigation")
  end

  def then_I_visit_the_navigation_steps_page_again
    click_on("Choose navigation")
  end

  def and_I_see_my_selected_preferences
    expect(page.find(:checkbox, match: :first)).to_not be_checked
    expect(page.all(:checkbox)[1]).to be_checked
  end
end
