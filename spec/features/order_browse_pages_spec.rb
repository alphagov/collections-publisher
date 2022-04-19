require "rails_helper"

RSpec.feature "Order browse pages" do
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_i_am_a_gds_editor
    and_external_services_are_stubbed
  end

  scenario "User chooses to display child pages in curated order" do
    given_there_are_browse_pages
    when_i_visit_the_browse_pages_index
    when_i_navigate_to_the_child_ordering_page
    and_i_select_curated_ordering
    and_i_submit_an_ordering
    then_i_see_my_curated_ordering
  end

  scenario "User chooses to display child pages in alphabetical order" do
    given_there_are_browse_pages
    when_i_visit_the_browse_pages_index
    when_i_navigate_to_the_child_ordering_page
    and_i_select_alphabetical_ordering_and_submit
    then_i_see_the_alphabetical_order
  end

  scenario "User triggers validation errors when curating child order" do
    given_there_are_browse_pages
    when_i_visit_the_browse_pages_index
    when_i_navigate_to_the_child_ordering_page
    and_i_select_curated_ordering
    and_i_fill_in_the_form_with_a_blank_input
    then_i_see_a_validation_error
  end

  def given_there_are_browse_pages
    parent = create(:mainstream_browse_page, :published, title: "Pizzas")
    @four_seasons = create(:mainstream_browse_page, parent: parent, title: "Four seasons")
    @pepperoni = create(:mainstream_browse_page, parent: parent, title: "Pepperoni")
  end

  def when_i_navigate_to_the_child_ordering_page
    click_on "Pizzas"
    click_on "Manage subtopic ordering"
  end

  def and_i_select_curated_ordering
    select "Curated", from: "Subtopic ordering"
  end

  def and_i_submit_an_ordering
    fill_in @four_seasons.title.to_s, with: "1"
    fill_in @pepperoni.title.to_s, with: "0"
    click_on "Save"
  end

  def then_i_see_my_curated_ordering
    titles = page.all(".gem-c-document-list__item-title").map(&:text)
    expect(titles).to eq([
      "Pepperoni",
      "Four seasons",
    ])
  end

  def and_i_select_alphabetical_ordering_and_submit
    select "Alphabetical", from: "Subtopic ordering"
    click_on "Save"
  end

  def then_i_see_the_alphabetical_order
    titles = page.all(".gem-c-document-list__item-title").map(&:text)
    expect(titles).to eq([
      "Four seasons",
      "Pepperoni",
    ])
  end

  def and_i_fill_in_the_form_with_a_blank_input
    fill_in @four_seasons.title.to_s, with: ""
    click_on "Save"
  end

  def then_i_see_a_validation_error
    expect(page).to have_content "Enter an index for #{@four_seasons.title}"
  end
end
