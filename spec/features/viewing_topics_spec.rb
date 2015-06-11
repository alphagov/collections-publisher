require 'rails_helper'

RSpec.describe "Viewing topics" do
  it "viewing the topic index" do
    # Given some parent topics with various number of children
    create(:topic, :published, :title => "Oil and Gas")
    business_tax = create(:topic, :published, :title => "Business Tax")
    create(:topic, :parent => business_tax, :title => "VAT")
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
  end
end
