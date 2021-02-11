require "rails_helper"

RSpec.feature "Visit Component Guide" do
  scenario "User views the component guide page" do
    when_i_visit_the_component_guide_index_page
    then_i_receive_a_valid_response
  end

  def when_i_visit_the_component_guide_index_page
    visit "/component-guide"
  end

  def then_i_receive_a_valid_response
    expect(page.status_code).to eq(200)
  end
end
