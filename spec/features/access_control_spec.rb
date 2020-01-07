require "rails_helper"

RSpec.feature "Access control" do
  include CommonFeatureSteps
  include NavigationSteps

  scenario "Non-GDS editor can't navigate to browse pages" do
    given_i_am_not_a_gds_editor
    when_i_visit_the_browse_pages_index
    then_i_am_informed_i_dont_have_access
  end

  def then_i_am_informed_i_dont_have_access
    expect(page).to have_content "Sorry, you don't seem to have the GDS Editor permission for this app"
    expect(page.status_code).to eql(403)
  end
end
