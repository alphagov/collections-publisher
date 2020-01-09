require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Create new step by step page" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps
  include GdsApi::TestHelpers::PublishingApi

  before do
    given_i_am_a_gds_editor
    setup_publishing_api
    stub_any_publishing_api_put_intent
  end

  scenario "User creates a new step by step page" do
    when_i_visit_the_new_step_by_step_form
    and_i_fill_in_the_form
    and_i_see_a_page_created_success_notice
    and_i_see_i_saved_it_last
    and_i_can_submit_the_step_by_step_for_2i_review
    and_i_can_preview_the_step_by_step
    when_i_visit_the_step_by_step_pages_index
    then_i_see_the_new_step_by_step_page
  end

  scenario "Validation fails" do
    when_i_visit_the_new_step_by_step_form
    and_i_fill_in_the_form_with_invalid_data
    then_i_see_a_validation_error
  end

  scenario "The slug has already been taken" do
    given_there_is_a_step_by_step_page_with_steps
    when_i_visit_the_new_step_by_step_form
    and_the_slug_has_been_taken
    and_i_fill_in_the_form_with_a_taken_slug
    then_i_see_a_slug_already_taken_error
  end

  def and_i_see_a_page_created_success_notice
    expect(page).to have_content("Step by step page was successfully created.")
  end

  def and_i_fill_in_the_form
    fill_in "Title", with: "How to bake a cake"
    fill_in "Slug", with: "how-to-bake-a-cake"
    fill_in "Introduction", with: "Learn how you can bake a cake"
    fill_in "Meta description", with: "How to bake a cake - learn how you can bake a cake"

    click_on "Save"
  end

  def and_i_fill_in_the_form_with_a_taken_slug
    fill_in "Title", with: "How to bake a cake"
    fill_in "Slug", with: @step_by_step_page.slug
    fill_in "Introduction", with: "Learn how you can bake a cake"
    fill_in "Meta description", with: "How to bake a cake - learn how you can bake a cake"

    click_on "Save"
  end

  def and_i_fill_in_the_form_with_invalid_data
    fill_in "Title", with: ""
    fill_in "Slug", with: ""
    fill_in "Introduction", with: ""
    fill_in "Meta description", with: ""
    click_on "Save"
  end

  def then_i_see_a_validation_error
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Slug can't be blank")
    expect(page).to have_content("Introduction can't be blank")
    expect(page).to have_content("Description can't be blank")
  end

  def and_the_slug_has_been_taken
    expect(
      Services.publishing_api,
    ).to(
      receive(:lookup_content_id)
      .with(base_path: "/#{@step_by_step_page.slug}", with_drafts: true)
      .and_return("A-TAKEN-CONTENT-ID"),
    )
  end

  def then_i_see_a_slug_already_taken_error
    expect(page).to have_content("Slug has already been taken")
  end

  def and_i_see_i_saved_it_last
    within(".gem-c-metadata") do
      expect(page).to have_content("Status: Draft")
      expect(page).to have_content("by Test author")
    end
  end
end
