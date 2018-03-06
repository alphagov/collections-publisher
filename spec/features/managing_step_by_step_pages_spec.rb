require "rails_helper"

RSpec.feature "Managing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_I_am_a_GDS_editor
  end

  scenario "User visits the index page" do
    given_there_is_published_step_by_step_page
    when_I_visit_the_step_by_step_pages_index
    then_I_see_the_step_by_step_page
  end

  scenario "User creates a new step by step page" do
    when_I_visit_the_new_step_by_step_form
    and_I_fill_in_the_form
    when_I_visit_the_step_by_step_pages_index
    then_I_see_the_new_step_by_step_page
  end

  scenario "Validation fails" do
    when_I_visit_the_new_step_by_step_form
    and_I_fill_in_the_form_with_invalid_data
    then_I_see_a_validation_error
  end

  def given_there_is_published_step_by_step_page
    @step_by_step_page = create(:step_by_step_page)
  end

  def and_I_visit_the_index_page
    when_I_visit_the_step_by_step_pages_index
  end

  def then_I_see_the_step_by_step_page
    expect(page).to have_content("How to be amazing")
  end

  def and_I_fill_in_the_form
    fill_in "Title", with: "How to bake a cake"
    fill_in "Slug", with: "how-to-bake-a-cake"
    fill_in "Introduction", with: "Learn how you can bake a cake"
    fill_in "Meta description", with: "How to bake a cake - learn how you can bake a cake"
    click_on "Save and continue"
  end

  def then_I_see_the_new_step_by_step_page
    expect(page).to have_content("How to bake a cake")
  end

  def and_I_fill_in_the_form_with_invalid_data
    fill_in "Title", with: ""
    fill_in "Slug", with: ""
    fill_in "Introduction", with: ""
    fill_in "Meta description", with: ""
    click_on "Save and continue"
  end

  def then_I_see_a_validation_error
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Slug can't be blank")
    expect(page).to have_content("Introduction can't be blank")
    expect(page).to have_content("Meta description can't be blank")
  end
end
