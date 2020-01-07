require "rails_helper"

RSpec.feature "Managing browse pages" do
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_i_am_a_gds_editor
    and_external_services_are_stubbed
  end

  scenario "Viewing browse page" do
    given_there_are_browse_pages
    when_i_visit_the_browse_pages_index
    then_i_see_the_top_level_pages
    when_i_click_on_a_browse_page
    then_i_see_the_child_pages
    when_i_click_on_a_child_page
    then_i_see_the_documents_tagged_to_it
  end

  def given_there_are_browse_pages
    create(:mainstream_browse_page, :published, title: "Money and Tax")
    citizenship = create(:mainstream_browse_page, :published, title: "Citizenship")
    create(:mainstream_browse_page, parent: citizenship, title: "Voting")
    british_citizenship = create(:mainstream_browse_page, parent: citizenship, title: "British citizenship")

    @linked_item_content_id1 = "6896f0f3-9b79-4ec3-9f16-892f7f35e921"
    @linked_item_content_id2 = "f608313e-524a-478a-ae73-03cfdc920bdd"
    publishing_api_has_linked_items(
      british_citizenship.content_id,
      items: [
        { base_path: "/naturalisation", title: "Naturalisation", content_id: @linked_item_content_id1 },
        { base_path: "/marriage", title: "Marriage", content_id: @linked_item_content_id2 },
      ],
    )
  end

  def then_i_see_the_top_level_pages
    titles = page.all(".tags-list tbody td:first-child").map(&:text)
    expect(titles).to eq([
      "Citizenship",
      "Money and Tax",
    ])
  end

  def when_i_click_on_a_browse_page
    click_on "Citizenship"
  end

  def then_i_see_the_child_pages
    child_titles = page.all(".children .tags-list tbody td:first-child").map(&:text)
    expect(child_titles).to eq([
      "British citizenship",
      "Voting",
    ])
  end

  def when_i_click_on_a_child_page
    click_on "British citizenship"
  end

  def then_i_see_the_documents_tagged_to_it
    tagged_document_titles = page.all(".tagged-document").map(&:text)
    expect(tagged_document_titles).to eq(%w(
      Naturalisation
      Marriage
    ))
    expect(page).to have_link(nil, href: "#{Plek.new.external_url_for('content-tagger')}/taggings/#{@linked_item_content_id1}")
    expect(page).to have_link(nil, href: "#{Plek.new.external_url_for('content-tagger')}/taggings/#{@linked_item_content_id2}")
  end
end
