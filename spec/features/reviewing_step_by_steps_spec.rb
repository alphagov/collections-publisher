require "rails_helper"

RSpec.feature "Reviewing step by step pages" do
  include CommonFeatureSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
    given_I_can_access_unreleased_features
    setup_publishing_api
  end

  scenario "User requests 2i review" do
    given_there_is_a_draft_step_by_step_page
    when_I_visit_the_submit_for_2i_page
    and_I_submit_the_form
    then_I_see_a_submitted_for_2i_success_notice
  end

  def given_I_can_access_unreleased_features
    stub_user.permissions << "Unreleased feature"
  end

  def when_I_visit_the_submit_for_2i_page
    visit step_by_step_page_submit_for_2i_path(@step_by_step_page)
  end

  def and_I_submit_the_form
    click_on "Submit for 2i"
  end

  def then_I_see_a_submitted_for_2i_success_notice
    expect(page).to have_content("Step by step page was successfully submitted for 2i")
  end
end
