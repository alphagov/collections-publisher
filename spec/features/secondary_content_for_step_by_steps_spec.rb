require "rails_helper"

RSpec.feature "Managing secondary content for step by step pages" do
  include CommonFeatureSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
    setup_publishing_api
  end

  scenario "User views secondary content links" do
    given_there_is_a_step_by_step_page_with_secondary_content
    when_I_visit_the_step_by_step_page
    when_I_visit_the_secondary_content_page
    then_can_I_see_the_existing_secondary_content_listed
  end

  def given_there_is_a_step_by_step_page_with_secondary_content
    @step_by_step_page = create(:step_by_step_page_with_secondary_content)
  end

  def when_I_visit_the_step_by_step_page
    visit step_by_step_page_path(@step_by_step_page)
  end

  def when_I_visit_the_secondary_content_page
    visit step_by_step_page_secondary_content_links_path(@step_by_step_page)
  end

  def then_can_I_see_the_existing_secondary_content_listed
    expect(find('tbody')).to have_content(@step_by_step_page.secondary_content_links.first.title)
  end
end
