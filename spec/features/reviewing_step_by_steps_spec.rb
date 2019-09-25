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
    and_I_see_a_not_yet_claimed_for_2i_prompt
    and_I_cannot_see_a_submit_for_2i_button
    when_I_view_internal_change_notes
    then_I_can_see_an_automated_change_note
  end

  scenario "User requests 2i review with additional comments" do
    given_there_is_a_draft_step_by_step_page
    when_I_visit_the_submit_for_2i_page
    and_I_fill_in_additional_comments
    and_I_submit_the_form
    then_I_see_a_submitted_for_2i_success_notice
    and_I_see_a_not_yet_claimed_for_2i_prompt
    and_I_cannot_see_a_submit_for_2i_button
    when_I_view_internal_change_notes
    then_I_can_see_an_automated_change_note
    and_I_can_see_additional_comments_in_the_change_note
  end

  def when_I_visit_the_submit_for_2i_page
    visit step_by_step_page_submit_for_2i_path(@step_by_step_page)
  end

  def when_I_view_internal_change_notes
    visit step_by_step_page_internal_change_notes_path(@step_by_step_page)
  end

  def and_I_submit_the_form
    click_on "Submit for 2i"
  end

  def and_I_fill_in_additional_comments
    fill_in "Additional comments", with: additional_comments
  end

  def then_I_see_a_submitted_for_2i_success_notice
    expect(page).to have_content("Step by step page was successfully submitted for 2i")
  end

  def and_I_see_a_not_yet_claimed_for_2i_prompt
    expect(page).to have_css(".govuk-inset-text", text: "Not yet claimed for 2i")
  end

  def and_I_cannot_see_a_submit_for_2i_button
    within(".app-side__actions") do
      expect(page).to_not have_link("Submit for 2i review")
    end
  end

  def then_I_can_see_an_automated_change_note
    expect(page).to have_content("Submitted for 2i")
  end

  def and_I_can_see_additional_comments_in_the_change_note
    expect(page).to have_content(additional_comments)
  end

  def additional_comments
    "additional comments for reviewer"
  end
end
