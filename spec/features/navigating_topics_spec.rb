require "rails_helper"

RSpec.feature "Navigating topics" do
  include PublishingApiHelpers

  scenario "User navigates topic pages" do
    given_there_are_topics_with_children
    when_I_visit_the_topics_page
    then_I_should_see_topics_in_alphabetical_order
    when_I_visit_a_topic_page

    given_topic_page_has_links
    when_I_visit_a_subtopic_page_without_lists
    then_I_should_see_that_the_items_have_not_been_curated

    and_I_see_the_linked_items_of_this_page

    when_I_go_to_the_parent_page
    and_I_visit_a_subtopic_with_lists
    then_I_see_curated_lists
    and_I_see_the_linked_items_of_this_page
  end

  def given_there_are_topics_with_children
    create(:topic, :published, title: "Oil and Gas")
    business_tax = create(:topic, :published, title: "Business Tax")
    @vat_topic = create(:topic, parent: business_tax, title: "VAT")
    create(:topic, parent: business_tax, title: "PAYE")
  end

  def when_I_visit_the_topics_page
    visit topics_path
  end

  def then_I_should_see_topics_in_alphabetical_order
    titles = page.all('.tags-list tbody td:first-child').map(&:text)
    expect(titles).to eq([
      'Business Tax',
      'Oil and Gas',
    ])

    child_titles = page.all('td.children li').map(&:text)
    first_words_of_titles = child_titles.map(&:split).map(&:first)
    expect(first_words_of_titles).to eq(%w(PAYE VAT))
  end

  def when_I_visit_a_topic_page
    click_on "Business Tax"
  end

  def given_topic_page_has_links
    stub_any_call_to_rummager_with_documents([
      { title: 'A link that only exists in Rummager.'}
    ])
  end

  def when_I_visit_a_subtopic_page_without_lists
    click_on 'PAYE'
  end

  def then_I_should_see_that_the_items_have_not_been_curated
    expect(page).to have_content 'Links for this tag have not been curated into lists'
  end

  def and_I_see_the_linked_items_of_this_page
    expect(page).to have_content 'A link that only exists in Rummager.'
  end

  def when_I_go_to_the_parent_page
    within '.breadcrumb' do
      click_on 'Business Tax'
    end
  end

  def and_I_visit_a_subtopic_with_lists
    @vat_topic.lists.create!
    click_on 'VAT'
  end

  def then_I_see_curated_lists
    expect(page).to have_content 'Links for this tag have been curated into lists'
  end
end
