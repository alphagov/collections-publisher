require "rails_helper"

RSpec.feature "Order browse pages" do
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_I_am_a_GDS_editor
    and_external_services_are_stubbed
  end

  scenario "User chooses to display child pages in curated order" do
    given_there_are_browse_pages
    when_I_visit_the_browse_pages_index
    when_I_navigate_to_the_child_ordering_page
    and_I_select_curated_ordering
    and_I_submit_an_ordering
    then_I_see_my_curated_ordering
  end

  scenario "User chooses to display child pages in alphabetical order" do
    given_there_are_browse_pages
    when_I_visit_the_browse_pages_index
    when_I_navigate_to_the_child_ordering_page
    and_I_select_alphabetical_ordering
    and_I_submit_the_form
    then_I_see_the_alphabetical_order
  end

  def given_there_are_browse_pages
    parent = create(:mainstream_browse_page, :published, title: "Pizzas")
    @four_seasons = create(:mainstream_browse_page, parent: parent, title: "Four seasons")
    @pepperoni = create(:mainstream_browse_page, parent: parent, title: "Pepperoni")
  end

  def when_I_navigate_to_the_child_ordering_page
    click_on 'Pizzas'
    click_on 'Manage child ordering'
  end

  def and_I_select_curated_ordering
    select 'curated', from: 'Child ordering'
  end

  def and_I_submit_an_ordering
    fill_in "#{@four_seasons.slug}", with: '1'
    fill_in "#{@pepperoni.slug}", with: '0'
    click_on 'Save'
  end

  def then_I_see_my_curated_ordering
    titles = page.all('.tags-list tbody td:first-child').map(&:text)
    expect(titles).to eq([
      'Pepperoni',
      'Four seasons',
    ])
  end

  def and_I_select_alphabetical_ordering
    select 'alphabetical', from: 'Child ordering'
  end

  def then_I_see_the_alphabetical_order
    titles = page.all('.tags-list tbody td:first-child').map(&:text)
    expect(titles).to eq([
      'Four seasons',
      'Pepperoni',
    ])
  end
end
