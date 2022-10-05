require "rails_helper"

RSpec.feature "Managing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  context "Given I'm a GDS Editor" do
    before do
      given_i_am_a_gds_editor
      setup_publishing_api
    end

    context "and I would like to create and manage steps on a step by step page" do
      scenario "User creates a step" do
        given_there_is_a_step_by_step_page
        when_i_visit_the_step_by_step_page
        and_i_create_a_new_step
        and_i_fill_in_the_form
        then_i_should_be_on_the_step_by_step_page
        and_i_can_see_a_success_message "Step was successfully created."
      end

      scenario "User edits step" do
        given_there_is_a_step_by_step_page_with_steps
        when_i_visit_the_step_by_step_page
        and_i_edit_the_first_step
        and_i_fill_the_edit_form_and_submit
        then_i_should_still_be_on_the_edit_step_page
        and_i_can_see_a_success_message "Step was successfully updated."
      end

      scenario "User deletes step", js: true do
        given_there_is_a_step_by_step_page_with_steps
        when_i_visit_the_step_by_step_page
        and_i_can_see_the_first_step
        and_i_delete_the_first_step
        then_the_step_is_deleted
      end
    end

    context "and I would like to reorder the steps on a step by step page" do
      before do
        allow(Services.publishing_api).to(
          receive(:lookup_content_id).with(
            base_path: "/how-to-be-the-amazing-1",
            with_drafts: true,
          ),
        )
      end

      scenario "User cannot reorder steps if none exist" do
        given_there_is_a_step_by_step_page
        when_i_visit_the_step_by_step_page
        then_i_cannot_see_the_button_to_reorder_steps
        and_i_visit_the_reorder_steps_page
        then_i_cannot_reorder_steps
      end

      scenario "User reorders steps", js: true do
        given_there_is_a_step_by_step_page_with_steps
        and_i_visit_the_reorder_steps_page
        and_i_reorder_the_steps
        and_i_see_the_steps_updated_on_the_step_by_step_details_page
      end
    end

    context "and I would like to leave a change note on a step by step page" do
      scenario "User leaves a change note" do
        given_there_is_a_step_by_step_page
        when_i_visit_the_change_notes_tab
        and_i_complete_a_change_note
        then_the_change_note_should_be_saved
      end

      scenario "User leaves a change note on a step by step that is scheduled" do
        given_there_is_a_scheduled_step_by_step_page
        when_i_visit_the_change_notes_tab
        and_i_complete_a_change_note
        then_the_change_note_should_be_saved
      end
    end
  end

  def and_i_visit_the_reorder_steps_page
    visit step_by_step_page_reorder_path(@step_by_step_page)
  end

  def and_i_create_a_new_step
    click_on "Add step"
  end

  def and_i_edit_the_first_step
    within(".gem-c-summary-list#steps") do
      click_on "Change", match: :first
    end
  end

  def and_i_reorder_the_steps
    click_on "Down", match: :first

    expect_update_worker
    click_on "Save"
  end

  def then_i_cannot_reorder_steps
    expect(page).not_to have_css("button", text: "Down")
    expect(page).not_to have_css("button", text: "Up")
    expect(page).to have_content("There are currently no steps to display.")
  end

  def then_i_cannot_see_the_button_to_reorder_steps
    expect(page).not_to have_css("button", text: "Reorder steps")
  end

  def and_i_can_see_the_first_step
    expect(page).to have_css(".govuk-summary-list__value", text: "Check how awesome you are")
  end

  def and_i_delete_the_first_step
    expect_update_worker

    accept_confirm do
      click_on "Delete", match: :first
    end
  end

  def then_the_step_is_deleted
    expect(page).not_to have_content("Check how awesome you are")
  end

  def and_i_fill_in_the_form_with_content
    fill_in "Step title", with: "Buy Mary Berry's 'Simple Cakes' book"
    choose "number"
    fill_in "Content, tasks and links", with: "* [Booky booky book book.com](http://bbbb.com)\n* [Words inside cardboard.com](http://wic.com)"
  end

  def and_i_fill_in_the_form
    and_i_fill_in_the_form_with_content
    and_i_click_on_save
  end

  def and_i_fill_the_edit_form_and_submit
    and_i_fill_in_the_form_with_content
    setup_publishing_api_request_expectations
    and_i_click_on_save
  end

  def setup_publishing_api_request_expectations
    allow(Services.publishing_api).to receive(:put_content)

    mocked_content_ids = {
      "/good/stuff" => "fd6b1901d-b925-47c5-b1ca-1e52197097e1",
      "/also/good/stuff" => "fd6b1901d-b925-47c5-b1ca-1e52197097e2",
      "/not/as/great" => "fd6b1901d-b925-47c5-b1ca-1e52197097e3",
    }

    mocked_content_ids.each do |base_path, content_id|
      stub_publishing_api_has_item(
        content_item(content_id, base_path),
      )
    end

    allow(Services.publishing_api).to(
      receive(:lookup_content_ids).and_return(mocked_content_ids),
    )
  end

  def content_item(content_id, base_path)
    {
      content_id:,
      base_path:,
      title: "BLAH BLAH",
    }
  end

  def and_i_click_on_save
    expect_update_worker

    click_on "Save step"
  end

  def and_i_see_the_step_on_the_step_by_step_details_page
    expect(page).to have_content("Add a new step")
    expect(page).to have_content("Buy Mary Berry's 'Simple Cakes' book")
  end

  def and_i_see_the_steps_updated_on_the_step_by_step_details_page
    expect(page).to have_css(".gem-c-summary-list#steps .govuk-summary-list__row:nth-child(1) .govuk-summary-list__value", text: "Dress like the Fonz")
    expect(page).to have_css(".gem-c-summary-list#steps .govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "Check how awesome you are")
  end

  def and_i_write_a_change_note
    fill_in "Internal note", with: "I've changed this step by step!"
  end

  def and_i_complete_a_change_note
    and_i_write_a_change_note
    click_on "Add internal note"
  end

  def then_the_change_note_should_be_saved
    expect(page).to have_content "Change note was successfully added."
    expect(page).to have_css(".gem-c-accordion", count: 1)
    within(".gem-c-accordion .govuk-accordion__section:first-of-type") do
      expect(page).to have_content("Current version")
      expect(page).to have_content("I've changed this step by step!")
    end
  end

  def then_i_should_still_be_on_the_edit_step_page
    edit_step_path = edit_step_by_step_page_step_path(@step_by_step_page.id, @step_by_step_page.steps.first.id)
    expect(current_url).to end_with edit_step_path
  end
end
