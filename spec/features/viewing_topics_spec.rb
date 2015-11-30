require 'rails_helper'

RSpec.describe "Viewing topics" do
  include PublishingApiHelpers

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
    expect(first_words_of_titles).to eq(%w(PAYE VAT))

    # When I visit a topic page
    click_on "Business Tax"

    # Then I should see the child topics in alphabetical order
    child_titles = page.all('.children .tags-list tbody td:first-child').map(&:text)
    expect(child_titles).to eq(%w(PAYE VAT))

    # Given the subtopic pages have links
    stub_any_call_to_rummager_with_documents([
      { title: 'A link that only exists in Rummager.'}
    ])

    # When I visit a subtopic page that has no lists
    click_on 'PAYE'

    # Then I should see the items are not curated
    expect(page).to have_content 'Links for this tag have not been curated into lists'

    # And I should see the link
    expect(page).to have_content 'A link that only exists in Rummager.'

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
    expect(page).to have_content 'A link that only exists in Rummager.'
  end

  it "disallows modification of archived topics" do
    stub_user.permissions << "GDS Editor"
    topic = create(:topic, :archived)

    visit edit_topic_path(topic)

    expect(page).to have_content 'You cannot modify an archived topic.'
  end

  it "allows users to archive published topics" do
    stub_any_call_to_rummager_with_documents([])
    stub_user.permissions << "GDS Editor"
    stub_put_content_to_publishing_api
    stub_publish_to_publishing_api

    rummager_deletion = stub_request(:delete, %r[https://rummager.test.gov.uk/*]).to_return(body: "{}")
    panopticon_deletion = stub_request(:delete, "https://panopticon.test.gov.uk/tags/specialist_sector/foo/bar.json").to_return(body: "{}")

    topic = create(:topic, :published, slug: 'bar', parent: create(:topic, slug: 'foo'))

    create(:topic, :published, title: 'The Successor Topic')

    visit topic_path(topic)

    click_link 'Archive topic'

    expect(page).to have_content 'Choose a topic to redirect to'

    select 'The Successor Topic', from: "archival_form_successor"

    click_button 'Archive and redirect to a topic'

    expect(topic.reload.archived?).to eql(true)
    expect(rummager_deletion).to have_been_requested
    expect(panopticon_deletion).to have_been_requested
  end

  it "doesn't archive a tag when panopticon doesn't want to delete it" do
    stub_any_call_to_rummager_with_documents([])
    stub_user.permissions << "GDS Editor"

    stub_request(:delete, "https://panopticon.test.gov.uk/tags/specialist_sector/foo/bar.json")
      .to_return(status: 409, body: "{}")

    topic = create(:topic, :published, slug: 'bar', parent: create(:topic, slug: 'foo'))

    create(:topic, :published, title: 'The Successor Topic')

    visit topic_path(topic)

    click_link 'Archive topic'
    select 'The Successor Topic', from: "archival_form_successor"
    click_button 'Archive and redirect to a topic'

    expect(page).to have_content 'The tag could not be deleted because there are documents tagged to it'
  end

  it "allows users to remove draft topics" do
    stub_any_call_to_rummager_with_documents([])
    stub_put_content_to_publishing_api
    stub_user.permissions << "GDS Editor"
    panopticon_deletion = stub_request(:delete, "https://panopticon.test.gov.uk/tags/specialist_sector/foo/bar.json").to_return(body: "{}")

    topic = create(:topic, :draft, slug: 'bar', parent: create(:topic, slug: 'foo'))

    visit topic_path(topic)

    click_link 'Remove topic'

    expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)

    expect(panopticon_deletion).to have_been_requested
  end
end
