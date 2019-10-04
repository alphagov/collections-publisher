require "rails_helper"

RSpec.feature "Contextual action buttons for step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
    given_I_can_access_unreleased_features
    setup_publishing_api
  end

  context "Step by step is in draft" do
    scenario "show the relevant actions to the step by step author" do
      given_there_is_a_step_by_step_page_with_a_link_report
      when_I_visit_the_step_by_step_page
      then_the_primary_action_should_be "Submit for 2i review"
      and_the_secondary_action_should_be "Preview"
      and_there_should_be_tertiary_actions_to %w(Delete)
    end
  end

  context "Step by step has been submitted for 2i" do
    background do
      given_there_is_a_step_by_step_that_has_been_submitted_for_2i
    end

    scenario "show the relevant actions to the step by step author" do
      and_I_am_the_step_by_step_author
      when_I_visit_the_step_by_step_page
      then_there_should_be_no_primary_action
      and_the_secondary_action_should_be "Preview"
      and_there_should_be_tertiary_actions_to %w(Delete)
    end

    scenario "show the relevant actions to the step by step 2i reviewer" do
      and_I_am_the_reviewer
      when_I_visit_the_step_by_step_page
      then_the_primary_action_should_be "Claim for 2i review"
      and_the_secondary_action_should_be "Preview"
      and_there_should_be_tertiary_actions_to %w(Delete)
    end
  end

  context "Step by step has been claimed for 2i" do
    background do
      given_there_is_a_step_by_step_that_has_been_claimed_for_2i
    end

    scenario "show the relevant actions to the step by step author" do
      and_I_am_the_step_by_step_author
      when_I_visit_the_step_by_step_page
      then_there_should_be_no_primary_action
      and_the_secondary_action_should_be "Preview"
      and_there_should_be_tertiary_actions_to %w(Delete)
    end

    scenario "show the relevant actions to the step by step 2i reviewer" do
      and_I_am_the_reviewer
      when_I_visit_the_step_by_step_page
      then_the_primary_action_should_be "Approve"
      and_the_secondary_action_should_be "Request changes"
      and_the_secondary_action_should_be "Preview"
      and_there_should_be_tertiary_actions_to %w(Delete)
    end
  end

  def then_the_primary_action_should_be(action_text)
    custom_error = "Couldn't find '#{action_text}' as a primary action in: \n #{action_html}"
    expect(page).to have_css(".app-side__actions .gem-c-button:not(.gem-c-button--secondary)", text: action_text), custom_error
  end

  def then_there_should_be_no_primary_action
    expect(page).not_to have_css(".app-side__actions .gem-c-button:not(.gem-c-button--secondary)")
  end

  def and_the_secondary_action_should_be(action_text)
    custom_error = "Couldn't find '#{action_text}' as a secondary action in: \n #{action_html}"
    expect(page).to have_css(".app-side__actions .gem-c-button--secondary", text: action_text), custom_error
  end

  def and_there_should_be_tertiary_actions_to(actions_text)
    actions_text.each do |action_text|
      custom_error = "Couldn't find '#{action_text}' as a tertiary action in: \n #{action_html}"
      expect(page).to have_css(".app-side__actions .govuk-link", text: action_text), custom_error
    end
  end

  def action_html
    find(".app-side__actions").native.inner_html.strip
  end
end
