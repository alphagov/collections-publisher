require "rails_helper"

RSpec.feature "Navigating topics" do
  scenario "User navigates topic pages" do
    given_there_are_topics_with_children
    when_i_visit_the_topics_page
    then_i_should_see_topics_in_alphabetical_order
    when_i_visit_a_topic_page

    given_topic_page_has_links
    when_i_visit_a_subtopic_page_without_lists
    then_i_should_see_that_the_items_have_not_been_curated

    and_i_see_the_linked_items_of_this_page

    when_i_go_to_the_parent_page
    and_i_visit_a_subtopic_with_lists
    then_i_see_curated_lists
    and_i_see_the_linked_items_of_this_page
  end

  def given_there_are_topics_with_children
    create(:topic, :published, title: "Oil and Gas")
    @business_tax = create(:topic, :published, title: "Business Tax")
    @vat_topic = create(:topic, parent: @business_tax, title: "VAT")
    @paye = create(:topic, parent: @business_tax, title: "PAYE")
  end

  def when_i_visit_the_topics_page
    visit topics_path
  end

  def then_i_should_see_topics_in_alphabetical_order
    titles = page.all(".tags-list tbody td:first-child").map(&:text)
    expect(titles).to eq([
      "Business Tax",
      "Oil and Gas",
    ])

    child_titles = page.all("td.children li").map(&:text)
    first_words_of_titles = child_titles.map(&:split).map(&:first)
    expect(first_words_of_titles).to eq(%w(PAYE VAT))
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

  def when_i_visit_a_subtopic_page_without_lists
    publishing_api_has_linked_items(
      @paye.content_id,
      items: [
        { title: "A link that only exists in Publishing API.", content_id: "cb2176d6-713e-42c7-8899-f856927c5eb8" },
      ],
    )
    click_on "PAYE"
  end

  def then_i_should_see_that_the_items_have_not_been_curated
    expect(page).to have_content "Links for this tag have not been curated into lists"
  end

  def and_i_see_the_linked_items_of_this_page
    expect(page).to have_content "A link that only exists in Publishing API."
  end

  def when_i_go_to_the_parent_page
    within ".breadcrumb" do
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
    @vat_topic.lists.create!
    click_on "VAT"
  end

  def then_i_see_curated_lists
    expect(page).to have_content "Links for this tag have been curated into lists"
  end
end
