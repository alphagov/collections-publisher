require "rails_helper"

RSpec.feature "Managing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
    setup_publishing_api
  end

  scenario "User creates a step" do
    given_there_is_a_step_by_step_page
    when_I_visit_the_step_by_step_page
    and_I_create_a_new_step
    and_I_fill_in_the_form
    then_the_content_is_sent_to_publishing_api
    and_I_see_the_step_on_the_step_by_step_details_page
  end

  scenario "User edits step" do
    given_there_is_a_step_by_step_page_with_steps
    when_I_visit_the_step_by_step_page
    and_I_edit_the_first_step
    then_I_can_see_the_edit_page
    and_I_fill_in_the_form
    then_the_content_is_sent_to_publishing_api
    and_I_see_the_step_on_the_step_by_step_details_page
  end

  scenario "User deletes step", js: true do
    given_there_is_a_step_by_step_page_with_steps
    when_I_visit_the_step_by_step_page
    and_I_can_see_the_first_step
    and_I_delete_the_first_step
    then_the_content_is_sent_to_publishing_api
    and_the_step_is_deleted
  end

  def given_there_is_a_step_by_step_page_with_steps
    @step_by_step_page = create(:step_by_step_page_with_steps)
  end

  def given_there_is_a_step_by_step_page
    @step_by_step_page = create(:step_by_step_page)
  end

  def when_I_visit_the_step_by_step_page
    visit step_by_step_page_path(@step_by_step_page)
  end

  def and_I_create_a_new_step
    click_on "Add a new step"
  end

  def and_I_edit_the_first_step
    within("table") do
      click_on "Edit", match: :first
    end
  end

  def and_I_can_see_the_first_step
    expect(page).to have_css("th", text: "Check how awesome you are")
  end

  def and_I_delete_the_first_step
    accept_confirm do
      click_on "Delete", match: :first
    end
  end

  def and_the_step_is_deleted
    expect(page).not_to have_css("th", text: "Check how awesome you are")
  end

  def then_I_can_see_the_edit_page
    expect(page).to have_css("label", text: "Step title")
  end

  def and_I_fill_in_the_form
    fill_in "Step title", with: "Buy Mary Berry's 'Simple Cakes' book"
    choose "number"
    choose "essential"
    fill_in "Content, tasks and links in this step", with: "* [Booky booky book book.com](http://bbbb.com)\n* [Words inside cardboard.com](http://wic.com)"
    click_on "Save step"
  end

  def and_I_see_the_step_on_the_step_by_step_details_page
    expect(page).to have_content("Add a new step")
    expect(page).to have_content("Buy Mary Berry's 'Simple Cakes' book")
  end
end
