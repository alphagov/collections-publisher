require "rails_helper"

RSpec.feature "Access control" do
  include CommonFeatureSteps
  include NavigationSteps

  scenario "Non-GDS Editor can't navigate to browse pages" do
    given_i_am_not_a_gds_editor
    when_i_visit_the_browse_pages_index
    then_i_am_informed_i_dont_have_access
  end

  describe "Landing page" do
    scenario "A Non-GDS editor cannot access this application" do
      given_i_am_not_a_gds_editor
      when_i_visit_the_root_path
      then_i_am_informed_i_dont_have_access
    end

    scenario "A GDS Editor accessing this application sees step by step page" do
      given_i_am_a_gds_editor
      when_i_visit_the_root_path
      i_see_the_step_by_step_index_page
    end
  end

  def then_i_am_informed_i_dont_have_access
    expect(page).to have_content "Sorry, you don't seem to have the GDS Editor permission for this app"
    expect(page.status_code).to eql(403)
  end

  def i_see_the_step_by_step_index_page
    expect(page).to have_content "Step by steps"
    expect(page).to have_link "Create new step by step"
    expect(page.status_code).to eql(200)
  end
end
