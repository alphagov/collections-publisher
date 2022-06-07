require "rails_helper"

RSpec.feature "Navigating topics" do
  scenario "User navigates topic pages" do
    given_there_are_topics_with_children
    when_i_visit_the_topics_page
    then_i_should_see_topics_in_alphabetical_order
    and_i_should_see_children_topics_in_alphabetical_order

    given_topic_page_has_links
    when_i_visit_a_topic_page
    and_i_visit_a_subtopic_page_without_lists
    then_i_should_see_that_the_items_have_not_been_curated
    and_i_see_the_linked_items_of_this_page

    when_i_go_to_the_parent_page
    and_i_visit_a_subtopic_with_lists
    then_i_see_curated_lists
    and_i_see_the_linked_items_of_this_page
  end

  def given_there_are_topics_with_children
    @oil_and_gas = create(:topic, :published, title: "Oil and Gas")
    @business_tax = create(:topic, :published, title: "Business Tax")
    @vat_topic = create(:topic, parent: @business_tax, title: "VAT")
    @paye = create(:topic, parent: @business_tax, title: "PAYE")
  end

  def when_i_visit_the_topics_page
    visit topics_path
  end

  def then_i_should_see_topics_in_alphabetical_order
    title_cells = page.all(".govuk-table__row td:first-child")
    expect(title_cells[0]).to have_link(@business_tax.title)
    expect(title_cells[0]).to have_link(@business_tax.base_path)
    expect(title_cells[1]).to have_link(@oil_and_gas.title)
    expect(title_cells[1]).to have_link(@oil_and_gas.base_path)
  end

  def and_i_should_see_children_topics_in_alphabetical_order
    child_titles = page.all(".govuk-table__row td[3]")
    expect(child_titles[0]).to have_link(@paye.title)
    expect(child_titles[0]).to have_link(@vat_topic.title)
  end

  def when_i_visit_a_topic_page
    click_on "Business Tax"
  end

  def given_topic_page_has_links
    publishing_api_has_linked_items(
      @business_tax.content_id,
      items: [
        { title: "A link that only exists in Publishing API.", content_id: "7eee3968-89df-4742-8f30-6c1cb58813cd" },
      ],
    )
  end

  def and_i_visit_a_subtopic_page_without_lists
    publishing_api_has_linked_items(
      @paye.content_id,
      items: [
        { title: "A link that only exists in Publishing API.", content_id: "cb2176d6-713e-42c7-8899-f856927c5eb8" },
      ],
    )
    click_on "PAYE"
  end

  def then_i_should_see_that_the_items_have_not_been_curated
    expect(page).to have_content "There are currently no curated lists for this topic. This topic will appear as an A to Z list."
  end

  def and_i_see_the_linked_items_of_this_page
    expect(page).to have_content "A link that only exists in Publishing API."
  end

  def when_i_go_to_the_parent_page
    within ".govuk-breadcrumbs__list" do
      click_on "Business Tax"
    end
  end

  def and_i_visit_a_subtopic_with_lists
    publishing_api_has_linked_items(
      @vat_topic.content_id,
      items: [
        { title: "A link that only exists in Publishing API.", content_id: "29941ec1-4a41-4bfd-86a9-5c866bbd4c7a" },
      ],
    )
    @vat_topic.lists.create!(name: "name")
    click_on "VAT"
  end

  def then_i_see_curated_lists
    expect(page).to have_content "Links for this tag have been curated into lists"
  end
end
