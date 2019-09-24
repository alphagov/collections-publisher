require "rails_helper"

RSpec.feature "Contextual action buttons for step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
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

  def then_the_primary_action_should_be(action_text)
    custom_error = "Couldn't find '#{action_text}' as a primary action in: \n #{action_html}"
    expect(page).to have_link(".app-side__actions .gem-c-button:not(.gem-c-button--secondary)", text: action_text), custom_error
  end

  def action_html
    find(".app-side__actions").native.inner_html.strip
  end
end
