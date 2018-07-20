require "rails_helper"

RSpec.feature "Managing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
    setup_publishing_api
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

  scenario "User deletes a step by step page", js: true do
    given_there_is_a_step_by_step_page_with_steps
    and_I_visit_the_publish_or_delete_page
    and_I_delete_the_step_by_step_page
    then_the_draft_is_discarded
    and_the_page_is_deleted
  end

  scenario "User publishes a page" do
    given_there_is_a_step_by_step_page_with_steps
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

  def given_there_is_a_published_step_by_step_page
    @step_by_step_page = create(:published_step_by_step_page)
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

  def then_I_see_that_the_url_isnt_valid
    expect(page).to have_content("Redirect path is invalid. Step by step page has not been unpublished.")
  end

  def and_I_see_a_success_notice
    expect(page).to have_content("Step by step page was successfully unpublished.")
  end

  def and_I_see_a_page_created_success_notice
    expect(page).to have_content("Step by step page was successfully created.")
  end

  def and_I_delete_the_step_by_step_page
    accept_confirm do
      click_on "Delete step by step"
    end
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

  def and_the_page_is_deleted
    expect(page).to_not have_content("How to bake a cake")
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
    expect(page).to have_content("Meta description can't be blank")
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

  def and_I_am_told_that_it_is_published
    expect(page).to have_content("has been published")
  end
end
