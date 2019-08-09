require "rails_helper"
require "gds_api/test_helpers/link_checker_api"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Managing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps
  include GdsApi::TestHelpers::LinkCheckerApi
  include GdsApi::TestHelpers::PublishingApi

  let(:schedule_time) { "2030-04-20 10:26:51 UTC" }

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

  scenario "User creates a new step by step page" do
    when_I_visit_the_new_step_by_step_form
    and_I_fill_in_the_form
    and_I_see_a_page_created_success_notice
    and_I_see_I_saved_it_last
    when_I_visit_the_step_by_step_pages_index
    then_I_see_the_new_step_by_step_page
  end

  scenario "Validation fails" do
    when_I_visit_the_new_step_by_step_form
    and_I_fill_in_the_form_with_invalid_data
    then_I_see_a_validation_error
  end

  scenario "The slug has already been taken" do
    given_there_is_a_step_by_step_page_with_steps
    when_I_visit_the_new_step_by_step_form
    and_the_slug_has_been_taken
    and_I_fill_in_the_form_with_a_taken_slug
    then_I_see_a_slug_already_taken_error
  end

  scenario "User edits step by step information when there is a step" do
    given_there_is_a_step_by_step_page_with_steps
    when_I_edit_the_step_by_step_page
    and_I_fill_in_the_edit_form
    then_I_see_the_new_step_by_step_page
  end

  scenario "User publishes a page" do
    given_there_is_a_step_by_step_page_with_steps
    when_I_view_the_step_by_step_page
    and_I_visit_the_publish_or_delete_page
    and_I_visit_the_publish_page
    and_I_publish_the_page
    then_the_page_is_published
    and_I_am_told_that_it_is_published
    then_I_see_the_step_by_step_page
    and_I_visit_the_publish_or_delete_page
    and_I_see_an_unpublish_button
  end

  scenario "User unpublishes a step by step page with a valid redirect url" do
    given_there_is_a_published_step_by_step_page
    when_I_view_the_step_by_step_page
    and_I_visit_the_publish_or_delete_page
    when_I_want_to_unpublish_the_page
    and_I_fill_in_the_form_with_a_valid_url
    then_the_page_is_unpublished
    and_I_see_a_success_notice
  end

  scenario "User unpublishes a step by step page with an invalid redirect url" do
    given_there_is_a_published_step_by_step_page
    when_I_view_the_step_by_step_page
    and_I_visit_the_publish_or_delete_page
    when_I_want_to_unpublish_the_page
    and_I_fill_in_the_form_with_an_invalid_url
    then_I_see_that_the_url_isnt_valid
    and_I_fill_in_the_form_with_an_empty_url
    then_I_see_that_the_url_isnt_valid
  end

  scenario "User deletes a step" do
    given_there_is_a_step_by_step_page_with_steps
    when_I_view_the_step_by_step_page
    and_I_delete_the_first_step
    and_I_see_a_step_deleted_success_notice
  end

  scenario "User deletes a step that has an existing link report" do
    given_there_is_a_step_by_step_page_with_a_link_report
    when_I_view_the_step_by_step_page
    and_I_delete_the_first_step
    and_I_see_a_step_deleted_success_notice
  end

  scenario "User deletes a draft step by step guide without change notes" do
    given_there_is_a_step_by_step_page
    and_I_visit_the_publish_or_delete_page
    and_I_delete_the_draft
    then_I_see_a_step_by_step_deleted_success_notice
  end

  scenario "User deletes a draft step by step guide with change notes" do
    given_there_is_a_step_by_step_page
    and_it_has_change_notes
    and_I_visit_the_publish_or_delete_page
    and_I_delete_the_draft
    then_I_see_a_step_by_step_deleted_success_notice
  end

  scenario "User reverts a step by step page" do
    given_there_is_a_published_step_by_step_page_with_unpublished_changes
    when_I_view_the_step_by_step_page
    and_I_visit_the_publish_or_delete_page
    when_I_want_to_revert_the_page
    then_I_see_a_page_reverted_success_notice
  end

  scenario "User cannot see Schedule button without Scheduling permissions" do
    given_there_is_a_draft_step_by_step_page
    and_I_visit_the_publish_or_delete_page
    then_there_should_be_no_schedule_button
  end

  context "Given I have Scheduling permissions" do
    before do
      given_I_have_scheduling_permissions
      stub_publishing_api_destroy_intent('/how-to-be-the-amazing-1')
    end

    scenario "User schedules publishing" do
      given_there_is_a_draft_step_by_step_page
      and_I_visit_the_scheduling_page
      and_I_fill_in_the_scheduling_form
      when_I_submit_the_form
      then_I_should_see "has been scheduled to publish"
      and_the_step_by_step_should_have_the_status "Scheduled"
      and_there_should_be_a_change_note "Minor update scheduled by Test author for publishing at #{schedule_time}"
    end

    scenario "User tries to schedule publishing for date in the past" do
      given_there_is_a_draft_step_by_step_page
      and_I_visit_the_scheduling_page
      and_I_fill_in_the_scheduling_form_with_a_date_in_the_past
      when_I_submit_the_form
      then_I_should_see "Scheduled at can't be in the past"
      and_the_step_by_step_should_have_the_status "Draft"
    end

    scenario "User tries to schedule publishing for an already scheduled step by step" do
      given_there_is_a_scheduled_step_by_step_page
      when_I_visit_the_publish_or_delete_page
      then_I_should_see "Scheduled to be published on"
      and_there_should_be_no_schedule_button
    end

    scenario "User unschedules publishing" do
      given_there_is_a_scheduled_step_by_step_page
      and_I_visit_the_publish_or_delete_page
      then_I_see_an_unschedule_button
      when_I_unschedule_publishing
      then_I_should_see "has been unscheduled"
      and_the_step_by_step_should_have_the_status "Draft"
      and_there_should_be_a_change_note "Publishing was unscheduled by Test author."
    end
  end

  def and_it_has_change_notes
    create(:internal_change_note, step_by_step_page_id: @step_by_step_page.id)
  end

  def and_I_visit_the_index_page
    when_I_visit_the_step_by_step_pages_index
  end

  def and_I_visit_the_publish_page
    visit step_by_step_page_publish_path(@step_by_step_page)
  end

  def when_I_want_to_unpublish_the_page
    click_on "Unpublish"
  end

  def when_I_want_to_revert_the_page
    allow(Services.publishing_api).to receive(:get_content).and_return(
      base_path: "/#{@step_by_step_page.slug}",
      title: "A step by step",
      description: "A description of a step by step",
      details: {
        step_by_step_nav: {
          introduction: [
            {
              content_type: "text/govspeak",
              content: "An introduction to the step by step journey."
            }
          ],
          steps: []
        }
      },
      state_history: { "1" => "published" },
      links: {},
    )

    click_on "Discard changes"
  end

  def and_I_fill_in_the_form_with_a_valid_url
    fill_in "Redirect to", with: "/micro-pigs-can-grow-to-the-size-of-godzilla"
    click_on "Unpublish step by step"
  end

  def and_I_fill_in_the_form_with_an_empty_url
    fill_in "Redirect to", with: ""
    click_on "Unpublish step by step"
  end

  def and_I_fill_in_the_form_with_an_invalid_url
    fill_in "Redirect to", with: "!"
    click_on "Unpublish step by step"
  end

  def and_I_delete_the_draft
    click_on "Delete"
  end

  def then_I_see_a_step_by_step_deleted_success_notice
    expect(page).to have_content("Step by step page was successfully deleted.")
  end

  def then_I_see_that_the_url_isnt_valid
    expect(page).to have_content("Redirect path is invalid. Step by step page has not been unpublished.")
  end

  def and_I_see_a_success_notice
    expect(page).to have_content("Step by step page was successfully unpublished.")
  end

  def and_I_see_a_page_created_success_notice
    expect(page).to have_content("Step by step page was successfully created.")
  end

  def when_I_view_the_step_by_step_page
    visit step_by_step_page_path(@step_by_step_page)
  end

  def when_I_edit_the_step_by_step_page
    visit edit_step_by_step_page_path(@step_by_step_page)
  end

  def then_I_see_the_step_by_step_page
    expect(page).to have_content("How to be amazing")
  end

  def and_I_visit_the_publish_or_delete_page
    visit step_by_step_page_publish_or_delete_path(@step_by_step_page)
  end

  def when_I_visit_the_publish_or_delete_page
    and_I_visit_the_publish_or_delete_page
  end

  def and_I_fill_in_the_form
    fill_in "Title", with: "How to bake a cake"
    fill_in "Slug", with: "how-to-bake-a-cake"
    fill_in "Introduction", with: "Learn how you can bake a cake"
    fill_in "Meta description", with: "How to bake a cake - learn how you can bake a cake"

    click_on "Save"
  end

  def and_I_fill_in_the_edit_form
    fill_in "Title", with: "How to bake a cake"
    fill_in "Introduction", with: "Learn how you can bake a cake"
    fill_in "Meta description", with: "How to bake a cake - learn how you can bake a cake"

    expect_update_worker
    click_on "Save"
  end

  def and_I_fill_in_the_form_with_a_taken_slug
    fill_in "Title", with: "How to bake a cake"
    fill_in "Slug", with: @step_by_step_page.slug
    fill_in "Introduction", with: "Learn how you can bake a cake"
    fill_in "Meta description", with: "How to bake a cake - learn how you can bake a cake"

    click_on "Save"
  end

  def then_I_see_the_new_step_by_step_page
    expect(page).to have_content("How to bake a cake")
  end

  def then_I_see_delete_and_publish_buttons
    within(".publish-or-delete") do
      expect(page).to have_css("a", text: "Delete step by step")
      expect(page).to have_css("a", text: "Publish changes")
      expect(page).to_not have_css("a", text: "Unpublish")
    end
  end

  def and_I_see_an_unpublish_button
    within(".publish-or-delete") do
      expect(page).to_not have_css("a", text: "Delete step by step")
      expect(page).to_not have_css("a", text: "Publish changes")
      expect(page).to have_css("a", text: "Unpublish")
    end
  end

  def and_I_fill_in_the_form_with_invalid_data
    fill_in "Title", with: ""
    fill_in "Slug", with: ""
    fill_in "Introduction", with: ""
    fill_in "Meta description", with: ""
    click_on "Save"
  end

  def then_I_see_a_validation_error
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Slug can't be blank")
    expect(page).to have_content("Introduction can't be blank")
    expect(page).to have_content("Description can't be blank")
  end

  def and_the_slug_has_been_taken
    expect(
      Services.publishing_api
    ).to(
      receive(:lookup_content_id)
      .with(base_path: "/#{@step_by_step_page.slug}", with_drafts: true)
      .and_return("A-TAKEN-CONTENT-ID")
    )
  end

  def then_I_see_a_slug_already_taken_error
    expect(page).to have_content("Slug has already been taken")
  end

  def and_I_publish_the_page
    click_on "Publish step by step"
  end

  def and_I_am_told_that_it_is_published
    expect(page).to have_content("has been published")
  end

  def and_I_delete_the_first_step
    within(".govuk-table tbody tr:first-child td") do
      click_on "Delete"
    end
  end

  def and_I_see_a_step_deleted_success_notice
    expect(page).to have_content("Step was successfully deleted.")
  end

  def then_I_see_a_page_reverted_success_notice
    expect(page).to have_content("Draft successfully discarded.")
  end

  def and_I_see_I_saved_it_last
    expect(page).to have_content("Last saved by Test author")
  end

  def given_I_have_scheduling_permissions
    stub_user.permissions << "Scheduling"
  end

  def and_I_visit_the_scheduling_page
    visit step_by_step_page_schedule_path(@step_by_step_page)
  end

  def when_I_visit_the_scheduling_page
    and_I_visit_the_scheduling_page
  end

  def and_I_fill_in_the_scheduling_form
    fill_in 'scheduled_at', with: schedule_time
  end

  def and_I_fill_in_the_scheduling_form_with_a_date_in_the_past
    fill_in 'scheduled_at', with: '1937-04-20 10:26:51 UTC'
  end

  def when_I_submit_the_form
    click_on 'Schedule to publish'
  end

  def and_there_should_be_no_schedule_button
    expect(page).not_to have_css("button", text: "Schedule to publish")
  end

  def then_there_should_be_no_schedule_button
    and_there_should_be_no_schedule_button
  end

  def then_I_should_see(content)
    expect(page).to have_content content
  end

  def and_the_step_by_step_should_have_the_status(status)
    visit step_by_step_pages_url
    expect(page).to have_css("tr[data-status=#{status.downcase}]")
  end

  def and_there_should_be_a_change_note(change_note)
    visit step_by_step_page_internal_change_notes_path(@step_by_step_page)
    expect(page).to have_content(change_note)
  end

  def then_I_see_an_unschedule_button
    within(".publish-or-delete") do
      expect(page).to_not have_css("button", text: "Schedule to publish")
      expect(page).to have_css("button", text: "Unschedule publishing")
    end
  end

  def when_I_unschedule_publishing
    click_on 'Unschedule publishing'
  end
end
