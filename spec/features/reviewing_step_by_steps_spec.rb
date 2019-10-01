require "rails_helper"

RSpec.feature "Reviewing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
    given_I_am_a_2i_reviewer
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

  scenario "User claims step by step for 2i review" do
    given_there_is_a_step_by_step_that_has_been_submitted_for_2i
    when_I_view_the_step_by_step_page
    and_I_claim_the_step_by_step_for_2i
    then_I_see_a_claimed_for_2i_prompt
    and_I_cannot_see_a_claim_for_2i_button
  end

  scenario "2i reviewer approves step by step" do
    given_there_is_a_step_by_step_that_has_been_claimed_for_2i
    and_I_am_the_reviewer
    when_I_visit_the_step_by_step_page
    and_I_approve_the_step_by_step_with_an_optional_note
    then_I_can_see_a_success_message "Step by step page was successfully 2i approved. Please let the author know."
    and_the_step_by_step_status_should_be "Approved 2i"
    and_I_should_see_my_optional_note_in_the_change_notes
  end

  def when_I_visit_the_submit_for_2i_page
    visit step_by_step_page_submit_for_2i_path(@step_by_step_page)
  end

  def when_I_view_internal_change_notes
    visit step_by_step_page_internal_change_notes_path(@step_by_step_page)
  end

  def when_I_view_the_step_by_step_page
    visit step_by_step_page_path(@step_by_step_page)
  end

  def and_I_approve_the_step_by_step_with_an_optional_note
    click_link "Approve"
    expect(page).to have_css(".govuk-caption-l", text: "Approve step by step")
    fill_in "additional_comment", with: "Please fix typo before publishing"
    click_button "Yes, approve 2i"
  end

  def and_I_should_see_my_optional_note_in_the_change_notes
    when_I_visit_the_change_notes_tab
    expect(page).to have_content "2i approved"
    expect(page).to have_content "Please fix typo before publishing"
  end

  def and_the_step_by_step_status_should_be(status)
    expect(page).to have_css(".gem-c-metadata", text: "Status: #{status}")
  end

  def and_I_submit_the_form
    click_on "Submit for 2i"
  end

  def and_I_fill_in_additional_comments
    fill_in "Additional comments", with: additional_comments
  end

  def and_I_claim_the_step_by_step_for_2i
    click_on "Claim for 2i review"
  end

  def then_I_see_a_submitted_for_2i_success_notice
    expect(page).to have_content("Step by step page was successfully submitted for 2i")
  end

  def and_I_see_a_not_yet_claimed_for_2i_prompt
    expect(page).to have_css(".govuk-inset-text", text: "Not yet claimed for 2i")
  end

  def then_I_see_a_claimed_for_2i_prompt
    expect(page).to have_css(".govuk-inset-text", text: "The 2i reviewer is #{stub_user.name}")
  end

  def and_I_cannot_see_a_submit_for_2i_button
    within(".app-side__actions") do
      expect(page).to_not have_link("Submit for 2i review")
    end
  end

  def and_I_cannot_see_a_claim_for_2i_button
    within(".app-side__actions") do
      expect(page).to_not have_link("Claim for 2i review")
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
