require "rails_helper"
require "gds_api/test_helpers/link_checker_api"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Managing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps
  include GdsApi::TestHelpers::LinkCheckerApi
  include GdsApi::TestHelpers::PublishingApi

  let(:yesterday) { Time.current - 1.day }

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

  scenario "User creates a new step by step page" do
    when_I_visit_the_new_step_by_step_form
    and_I_fill_in_the_form
    and_I_see_a_page_created_success_notice
    and_I_see_I_saved_it_last
    when_I_visit_the_step_by_step_pages_index
    then_I_see_the_new_step_by_step_page
  end

  scenario "User visits an existing step by step page" do
    given_there_is_a_step_by_step_page
    when_I_view_the_step_by_step_page
    then_I_can_see_a_summary_section
    and_I_can_edit_the_summary_section
    and_I_can_see_a_steps_overview_section_with_no_steps
    and_I_cannot_check_for_broken_links
    and_I_cannot_reorder_the_steps
    and_I_can_see_a_where_to_show_section_with_links "Edit"
    and_I_can_see_a_metadata_section
  end

  scenario "User visits an existing step by step page with steps" do
    given_there_is_a_step_by_step_page_with_steps
    when_I_view_the_step_by_step_page
    then_I_can_see_a_summary_section
    and_I_can_edit_the_summary_section
    and_I_can_see_a_steps_overview_section
    and_I_can_edit_and_delete_steps
    and_I_can_reorder_the_steps
    and_I_can_see_a_where_to_show_section_with_links "Edit"
    and_I_can_see_a_metadata_section
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
    given_there_is_a_draft_step_by_step_page
    when_I_view_the_step_by_step_page
    and_when_I_click_button "Publish"
    then_I_am_told_that_it_is_published
    then_I_see_the_step_by_step_page
    and_I_see_an_unpublish_button
    and_I_see_a_view_on_govuk_link
    and_there_should_be_a_change_note "First published by Test author"
  end

  scenario "User unpublishes a step by step page with a valid redirect url" do
    given_there_is_a_published_step_by_step_page
    when_I_view_the_step_by_step_page
    and_I_want_to_unpublish_the_page
    and_I_fill_in_the_form_with_a_valid_url
    then_the_page_is_unpublished
    and_I_see_a_success_notice
  end

  scenario "User unpublishes a step by step page with an invalid redirect url" do
    given_there_is_a_published_step_by_step_page
    when_I_view_the_step_by_step_page
    and_I_want_to_unpublish_the_page
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
    when_I_view_the_step_by_step_page
    and_I_delete_the_draft
    then_I_see_a_step_by_step_deleted_success_notice
  end

  scenario "User deletes a draft step by step guide with change notes" do
    given_there_is_a_step_by_step_page
    and_it_has_change_notes
    when_I_view_the_step_by_step_page
    and_I_delete_the_draft
    then_I_see_a_step_by_step_deleted_success_notice
  end

  scenario "User reverts a step by step page" do
    given_there_is_a_published_step_by_step_page_with_unpublished_changes
    when_I_view_the_step_by_step_page
    when_I_want_to_revert_the_page
    then_I_see_a_page_reverted_success_notice
  end

  scenario "User publishes changes to a published step by step page" do
    given_there_is_a_published_step_by_step_page_with_unpublished_changes
    when_I_view_the_step_by_step_page
    and_when_I_click_button "Publish"
    then_I_should_see_a_publish_form_with_changenotes
    and_when_I_click_the_publish_button_in_the_publish_form
    then_I_am_told_that_it_is_published
  end

  scenario "User publishes and then makes more changes to a step by step page" do
    given_I_am_assigned_to_a_published_step_by_step_page_with_unpublished_changes
    and_I_visit_the_publish_page
    and_I_publish_the_page
    then_there_should_be_a_change_note "Published by #{stub_user.name}"
    when_I_view_the_step_by_step_page
    and_I_delete_the_first_step
    then_there_should_be_a_change_note "Draft saved by #{stub_user.name}"
  end

  context "Scheduling" do
    before do
      stub_publishing_api_destroy_intent('/how-to-be-the-amazing-1')
    end

    scenario "User schedules publishing" do
      given_there_is_a_draft_step_by_step_page_with_secondary_content_and_navigation_rules
      and_I_visit_the_scheduling_page
      and_I_fill_in_the_scheduling_form
      when_I_submit_the_form
      then_I_should_see "has been scheduled to publish"
      and_the_step_by_step_should_have_the_status "Scheduled"
      and_there_should_be_a_change_note "Scheduled by Test author for publishing at 10:26am on 20 April 2030"
      and_the_step_by_step_is_not_editable
      when_I_view_the_step_by_step_page
      then_I_can_see_a_summary_section
      but_I_cannot_edit_the_summary_section
      and_I_can_see_a_steps_overview_section
      but_I_cannot_edit_or_delete_steps
      and_I_cannot_reorder_the_steps
      and_I_can_see_a_where_to_show_section_with_links "Edit"
      then_I_can_preview_the_step_by_step
      and_the_steps_can_be_checked_for_broken_links
    end

    scenario "User tries to schedule publishing for date in the past" do
      given_there_is_a_draft_step_by_step_page
      and_I_visit_the_scheduling_page
      then_inputs_should_have_tomorrows_date
      and_I_fill_in_the_scheduling_form_with_a_date_in_the_past
      when_I_submit_the_form
      then_I_should_see "Scheduled at can't be in the past"
      and_I_can_still_see_the_date_and_time_values_I_entered
      and_the_step_by_step_should_have_the_status "Draft"
    end

    scenario "User tries to schedule publishing for an already scheduled step by step" do
      given_there_is_a_scheduled_step_by_step_page
      when_I_view_the_step_by_step_page
      then_I_should_see "Scheduled to be published at"
      and_there_should_be_no_schedule_button
    end

    scenario "User unschedules publishing" do
      given_there_is_a_scheduled_step_by_step_page
      when_I_view_the_step_by_step_page
      then_I_see_an_unschedule_button
      when_I_unschedule_publishing
      then_I_should_see "has been unscheduled"
      and_the_step_by_step_should_have_the_status "Draft"
      and_there_should_be_a_change_note "Publishing was unscheduled by Test author."
    end

    scenario "User tries using invalid values for schedule date and time" do
      given_there_is_a_draft_step_by_step_page
      and_I_visit_the_scheduling_page
      and_I_fill_in_the_scheduling_form_with_nonsense_data
      when_I_submit_the_form
      then_I_should_see "Enter a valid date", :at_the_top_of_the_page
      and_I_should_see "Enter a valid time", :at_the_top_of_the_page
      and_I_should_see "Enter a valid date", :within_the_date_component
      and_I_should_see "Enter a valid time", :within_the_time_component
    end
  end

  scenario "A step doesn't have any content" do
    given_there_is_a_step_by_step_page_with_steps_missing_content
    when_I_view_the_step_by_step_page
    then_I_should_see "Step by steps cannot be published until all steps have content."
    and_I_should_see_an_inset_prompt
    and_the_prompt_should_contain_link_to_steps_section "Add content to all your steps"
    and_there_should_be_no_publish_button
    and_there_should_be_no_schedule_button
  end

  scenario "A step has not been tested for broken links" do
    given_there_is_a_step_that_has_not_been_tested_for_broken_links
    when_I_view_the_step_by_step_page
    then_the_step_should_have_no_broken_link_summary
  end

  scenario "A step contains no broken links" do
    given_there_is_a_step_that_has_no_broken_links
    when_I_view_the_step_by_step_page
    then_the_step_should_confirm_it_has_no_broken_links
  end

  scenario "A step contains a single broken link" do
    given_there_is_a_step_with_a_broken_link
    when_I_view_the_step_by_step_page
    then_the_step_should_confirm_it_has_one_broken_link
  end

  scenario "A step contains multiple broken links" do
    given_there_is_a_step_with_multiple_broken_links
    when_I_view_the_step_by_step_page
    then_the_step_should_confirm_it_has_multiple_broken_links
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

  def and_I_want_to_unpublish_the_page
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
    click_on "Unpublish"
  end

  def and_I_fill_in_the_form_with_an_empty_url
    fill_in "Redirect to", with: ""
    click_on "Unpublish"
  end

  def and_I_fill_in_the_form_with_an_invalid_url
    fill_in "Redirect to", with: "!"
    click_on "Unpublish"
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

  def then_I_can_see_a_summary_section
    within_summary_section do
      expect(page).to have_content "Content"
      expect(page).to have_content "Title #{@step_by_step_page.title}"
      expect(page).to have_content "Slug #{@step_by_step_page.slug}"
      expect(page).to have_content "Introduction #{@step_by_step_page.introduction}"
      expect(page).to have_content "Description #{@step_by_step_page.description}"
    end
  end

  def and_I_can_edit_the_summary_section
    within_summary_section do
      expect(page).to have_link("Edit", :href => edit_step_by_step_page_path(@step_by_step_page))
    end
  end

  def but_I_cannot_edit_the_summary_section
    within_summary_section do
      expect(page).not_to have_link("Edit")
    end
  end

  def within_summary_section
    expect(page).to have_css(".gem-c-summary-list#content")
    within(".gem-c-summary-list#content") do
      yield
    end
  end

  def and_I_can_see_a_steps_overview_section_with_no_steps
    expect(page).not_to have_css('.gem-c-summary-list#steps .govuk-summary-list__row')
    expect(page).to have_content('No steps have been added yet.')
  end

  def and_I_cannot_check_for_broken_links
    expect(page).not_to have_link('Check for broken links')
  end

  def and_I_can_see_a_steps_overview_section
    within('.gem-c-summary-list#steps') do
      expect(page).to have_selector(".govuk-heading-m", text: "Steps")
      expect(page).to have_css('.govuk-summary-list__row', count: 2)
      expect(page).to have_step_text_in_row(row: 1, text: 'Check how awesome you are')
      expect(page).to have_step_text_in_row(row: 2, text: 'Dress like the Fonz')
    end
  end

  def have_step_text_in_row(row:, text:)
    have_selector(".govuk-summary-list__row:nth-child(#{row}) .govuk-summary-list__value", text: text)
  end

  def and_I_can_edit_and_delete_steps
    all('.gem-c-summary-list#steps .govuk-summary-list__actions').each do |step|
      expect(step).to have_link("Edit")
      expect(step).to have_link("Delete")
    end
  end

  def but_I_cannot_edit_or_delete_steps
    all('.gem-c-summary-list#steps .govuk-summary-list__actions').each do |step|
      expect(step).not_to have_link("Edit")
      expect(step).not_to have_link("Delete")
    end
  end

  def and_I_can_reorder_the_steps
    expect(page).to have_link("Reorder", href: step_by_step_page_reorder_path(@step_by_step_page))
  end

  def and_I_cannot_reorder_the_steps
    expect(page).to_not have_link("Reorder", exact: true)
  end

  def and_I_can_see_a_where_to_show_section_with_links(link_text)
    within(".gem-c-summary-list#where-to-show") do
      expect(page).to have_content "Where to show this step by step"
      expect(page).to have_link(link_text, :href => step_by_step_page_navigation_rules_path(@step_by_step_page))
      expect(page).to have_link(link_text, :href => step_by_step_page_secondary_content_links_path(@step_by_step_page))
    end
  end

  def and_I_can_see_a_metadata_section
    within(".gem-c-metadata") do
      expect(page).to have_content("Status: Draft")
      expect(page).to have_content("Last saved")
      expect(page).to have_content("Created")
    end
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
    within(".app-side__actions") do
      expect(page).to have_css("a", text: "Delete")
      expect(page).to have_css("a", text: "Publish")
      expect(page).to_not have_css("a", text: "Unpublish")
    end
  end

  def and_I_see_an_unpublish_button
    within(".app-side__actions") do
      expect(page).to_not have_css("a", text: "Delete")
      expect(page).to_not have_css("a", text: "Publish")
      expect(page).to have_css("a", text: "Unpublish")
    end
  end

  def and_I_see_a_view_on_govuk_link
    within(".app-side__actions") do
      expect(page).to have_css("a", text: "View on GOV.UK")
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
    click_on "Publish"
  end

  def then_I_am_told_that_it_is_published
    expect(page).to have_content("has been published")
  end

  def and_I_delete_the_first_step
    within(".gem-c-summary-list#steps .govuk-summary-list__row:first-child") do
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
    within(".gem-c-metadata") do
      expect(page).to have_content("Status: Draft")
      expect(page).to have_content("by Test author")
    end
  end

  def and_I_visit_the_scheduling_page
    visit step_by_step_page_schedule_path(@step_by_step_page)
  end

  alias_method :when_I_visit_the_scheduling_page, :and_I_visit_the_scheduling_page

  def when_I_click_button(button_text)
    begin
      click_button button_text, exact: true
    rescue Capybara::ElementNotFound
      # some button-like things are actually marked up as link
      click_link button_text, exact: true
    end
  end

  alias_method :and_when_I_click_button, :when_I_click_button

  def and_when_I_click_the_publish_button_in_the_publish_form
    click_button "Publish", exact: true
  end

  def then_I_should_see_a_publish_form_with_changenotes
    expect(page).to have_content("Notify users about this change?")
    expect(page).to have_css('input[type="radio"][name="update_type"]', count: 2)
    expect(page).to have_css('textarea[name="change_note"]')
  end

  def and_I_fill_in_the_scheduling_form
    fill_in 'schedule[date][year]', with: "2030"
    fill_in 'schedule[date][month]', with: "04"
    fill_in 'schedule[date][day]', with: "20"
    fill_in 'schedule[time]', with: "10:26am"
  end

  def and_I_fill_in_the_scheduling_form_with_a_date_in_the_past
    fill_in 'schedule[date][year]', with: yesterday.year
    fill_in 'schedule[date][month]', with: yesterday.month
    fill_in 'schedule[date][day]', with: yesterday.day
    fill_in 'schedule[time]', with: "10:26am"
  end

  def and_I_fill_in_the_scheduling_form_with_nonsense_data
    fill_in 'schedule[date][year]', with: Time.current.year
    fill_in 'schedule[date][month]', with: ""
    fill_in 'schedule[date][day]', with: Time.current.day
    fill_in 'schedule[time]', with: "foo"
  end

  def then_inputs_should_have_tomorrows_date
    tomorrow = Time.current.tomorrow
    expect(find_field('schedule[date][year]').value).to eq tomorrow.year.to_s
    expect(find_field('schedule[date][month]').value).to eq tomorrow.month.to_s
    expect(find_field('schedule[date][day]').value).to eq tomorrow.day.to_s
    expect(find_field('schedule[time]').value).to eq "9:00am"
  end

  def and_I_can_still_see_the_date_and_time_values_I_entered
    expect(find_field('schedule[date][day]').value).to eq yesterday.day.to_s
    expect(find_field('schedule[time]').value).to eq "10:26am"
  end

  def when_I_submit_the_form
    click_on 'Schedule'
  end

  def and_there_should_be_no_schedule_button
    expect(page).not_to have_link("Schedule")
  end

  alias_method :then_there_should_be_no_schedule_button, :and_there_should_be_no_schedule_button

  def and_I_should_see_an_inset_prompt
    expect(page).to have_css('.govuk-inset-text', text: "To publish this step by step you need to")
  end

  def and_the_prompt_should_contain_link_to_steps_section(prompt)
    within('.govuk-inset-text') do
      expect(page).to have_link(prompt, href: '#steps')
    end
  end

  def then_I_should_see(content, scope = nil)
    scope_selector = case scope
                     when :at_the_top_of_the_page
                       '.gem-c-error-summary'
                     when :within_the_date_component
                       'form > .govuk-form-group:not(.app-c-autocomplete)'
                     when :within_the_time_component
                       'form > .app-c-autocomplete'
                     else
                       'body'
                     end
    within scope_selector do
      expect(page).to have_content content
    end
  end

  alias_method :and_I_should_see, :then_I_should_see

  def and_the_step_by_step_should_have_the_status(status)
    visit step_by_step_pages_url
    expect(page).to have_content(status)
  end

  def and_there_should_be_a_change_note(change_note)
    visit step_by_step_page_internal_change_notes_path(@step_by_step_page)
    expect(page).to have_content(change_note)
  end

  alias_method :then_there_should_be_a_change_note, :and_there_should_be_a_change_note

  def then_I_see_an_unschedule_button
    within(".app-side__actions") do
      expect(page).to_not have_css("a", text: "Schedule")
      expect(page).to have_css("a", text: "Unschedule")
    end
  end

  def when_I_unschedule_publishing
    click_on 'Unschedule'
  end

  def and_the_step_by_step_is_not_editable
    then_there_should_be_no_reorder_steps_tab

    when_I_view_the_step_by_step_page
    then_I_can_see_the_steps
    and_I_cannot_edit_any_steps
    and_I_cannot_delete_any_steps
    and_I_cannot_add_new_steps

    when_I_edit_the_step_by_step_page
    then_I_can_see_the_step_by_step_details
    and_I_cannot_edit_the_step_by_step_details

    when_I_visit_the_navigation_rules_page
    then_I_see_pages_included_in_navigation
    but_there_is_no_select_component

    when_I_visit_the_secondary_content_page
    then_I_can_see_the_existing_secondary_links
    and_I_cannot_add_secondary_content_link
    and_I_cannot_delete_secondary_content_links

    when_I_view_the_step_by_step_page
    then_there_should_be_no_publish_button
    then_there_should_be_no_discard_changes_button
    then_there_should_be_no_unpublish_button
  end

  def then_there_should_be_no_reorder_steps_tab
    expect(page).to_not have_link("Reorder steps", :href => step_by_step_page_reorder_path(@step_by_step_page))
  end

  def then_I_can_see_the_steps
    expect(find('.gem-c-summary-list#steps .govuk-summary-list__row:nth-child(1) .govuk-summary-list__value')).to have_content(@step_by_step_page.steps.first.title)
  end

  def and_I_cannot_edit_any_steps
    expect(page).to_not have_button("Edit")
  end

  def and_I_cannot_delete_any_steps
    expect(page).to_not have_button("Delete")
  end

  def and_I_cannot_add_new_steps
    expect(page).to_not have_button("Add a new step")
  end

  def then_I_can_see_the_step_by_step_details
    expect(page).to have_content("How to be amazing")
    expect(page).to have_content("how-to-be-the-amazing-1")
    expect(page).to have_content("Find out the steps to become amazing")
    expect(page).to have_content("How to be amazing - find out the steps to become amazing")
  end

  def and_I_cannot_edit_the_step_by_step_details
    expect(page).to_not have_field("step_by_step_page[title]")
    expect(page).to_not have_field("step_by_step_page[slug]")
    expect(page).to_not have_field("step_by_step_page[introduction]")
    expect(page).to_not have_field("step_by_step_page[description]")
    expect(page).to_not have_css("button", text: "Save")
  end

  def when_I_visit_the_navigation_rules_page
    visit step_by_step_page_navigation_rules_path(@step_by_step_page)
  end

  def then_I_see_pages_included_in_navigation
    expect(page).to have_link("Also good stuff", href: "https://draft-origin.test.gov.uk/also/good/stuff")
    expect(page).to have_content("Always show navigation")
  end

  def but_there_is_no_select_component
    expect(page).not_to have_css("select")
  end

  def when_I_visit_the_secondary_content_page
    visit step_by_step_page_secondary_content_links_path(@step_by_step_page)
  end

  def then_I_can_see_the_existing_secondary_links
    expect(find('tbody')).to have_content(@step_by_step_page.secondary_content_links.first.title)
  end

  def and_I_cannot_add_secondary_content_link
    expect(page).to_not have_css("h2", text: "Add new secondary link")
    expect(page).to_not have_css("button", text: "Add secondary link")
  end

  def and_I_cannot_delete_secondary_content_links
    within("tbody") do
      expect(page).to_not have_css("button", text: "Delete")
    end
  end

  def then_there_should_be_no_publish_button
    within(".app-side__actions") do
      expect(page).to_not have_link("Publish")
    end
  end

  alias_method :and_there_should_be_no_publish_button, :then_there_should_be_no_publish_button

  def then_there_should_be_no_discard_changes_button
    within(".app-side__actions") do
      expect(page).to_not have_css("a", text: "Discard changes")
    end
  end

  def then_there_should_be_no_unpublish_button
    within(".app-side__actions") do
      expect(page).to_not have_css("a", text: "Unpublish")
    end
  end

  def then_I_can_preview_the_step_by_step
    within(".app-side__actions") do
      expect(page).to have_link("Preview")
    end
  end

  def and_the_steps_can_be_checked_for_broken_links
    expect(page).to have_button("Check for broken links")
  end

  def then_the_step_should_have_no_broken_link_summary
    expect(first_step_summary).to_not have_css(".step-broken-links__summary")
  end

  def then_the_step_should_confirm_it_has_no_broken_links
    expect(first_step_summary).to have_css(".app-broken-link-status--pass", text: "No broken links")
  end

  def then_the_step_should_confirm_it_has_one_broken_link
    expect(first_step_summary).to have_css(".app-broken-link-status--fail", text: "1 broken link found")
  end

  def then_the_step_should_confirm_it_has_multiple_broken_links
    expect(first_step_summary).to have_css(".app-broken-link-status--fail", text: "2 broken links found")
  end

  def first_step_summary
    find(".gem-c-summary-list#steps .govuk-summary-list__row:first-child .govuk-summary-list__value")
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
