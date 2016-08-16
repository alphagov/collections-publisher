require 'rails_helper'

RSpec.feature "Managing browse pages" do
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_I_am_a_GDS_editor
    and_external_services_are_stubbed
  end

  scenario "Viewing browse page" do
    given_there_are_browse_pages
    when_I_visit_the_browse_pages_index
    then_I_see_the_top_level_pages
    when_I_click_on_a_page
    then_I_see_the_child_pages
  end

  def given_there_are_browse_pages
    create(:mainstream_browse_page, :published, title: "Money and Tax")
    citizenship = create(:mainstream_browse_page, :published, title: "Citizenship")
    create(:mainstream_browse_page, parent: citizenship, title: "Voting")
    create(:mainstream_browse_page, parent: citizenship, title: "British citizenship")
  end

  def then_I_see_the_top_level_pages
    titles = page.all('.tags-list tbody td:first-child').map(&:text)
    expect(titles).to eq([
      'Citizenship',
      'Money and Tax',
    ])
  end

  def when_I_click_on_a_page
    click_on "Citizenship"
  end

  def then_I_see_the_child_pages
    child_titles = page.all('.children .tags-list tbody td:first-child').map(&:text)
    expect(child_titles).to eq([
      'British citizenship',
      'Voting',
    ])
  end
end
