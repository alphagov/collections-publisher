require 'rails_helper'

RSpec.describe "Viewing topics" do
  it "viewing the topic index" do
    # Given some parent topics with various number of children
    create(:topic, :published, :title => "Oil and Gas")
    business_tax = create(:topic, :published, :title => "Business Tax")
    vat_topic = create(:topic, :parent => business_tax, :title => "VAT")
    create(:topic, :parent => business_tax, :title => "PAYE")

    # When I visit the topics index
    visit topics_path

    # Then I should see the top-level topics in alphabetical order
    titles = page.all('.tags-list tbody td:first-child').map(&:text)
    expect(titles).to eq([
      'Business Tax',
      'Oil and Gas',
    ])

    child_titles = page.all('td.children li').map(&:text)
    first_words_of_titles = child_titles.map(&:split).map(&:first)
    expect(first_words_of_titles).to eq([
      'PAYE',
      'VAT',
    ])

    # When I visit a topic page
    click_on "Business Tax"

    # Then I should see the child topics in alphabetical order
    child_titles = page.all('.children .tags-list tbody td:first-child').map(&:text)
    expect(child_titles).to eq([
      'PAYE',
      'VAT',
    ])

    # Given the subtopic pages have links
    stub_content_api(grouped_results: [
      { title: 'A link that only exists in the Content API'}
    ])

    # When I visit a subtopic page that has no lists
    click_on 'PAYE'

    # Then I should see the items are not curated
    expect(page).to have_content 'Links for this tag have not been curated into lists'

    # And I should see the link
    expect(page).to have_content 'A link that only exists in the Content API'

    # When I go back a level
    within '.breadcrumb' do
      click_on 'Business Tax'
    end

    # And I visit the subtopic page that does have lists
    vat_topic.lists.create!
    click_on 'VAT'

    # Then I should see the items are curated
    expect(page).to have_content 'Links for this tag have been curated into lists'

    # And I should see the link
    expect(page).to have_content 'A link that only exists in the Content API'
  end
end
