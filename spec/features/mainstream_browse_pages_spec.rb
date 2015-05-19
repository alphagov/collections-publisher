require 'rails_helper'

RSpec.describe "managing mainstream browse pages" do

  before :each do
    stub_user.permissions << "GDS Editor"
    stub_all_panopticon_tag_calls
  end

  it "viewing the browse page index" do
    # Given some parent topics with various number of children
    create(:mainstream_browse_page, :published, :title => "Money and Tax")
    citizenship = create(:mainstream_browse_page, :published, :title => "Citizenship")
    create(:mainstream_browse_page, :parent => citizenship, :title => "Voting")
    create(:mainstream_browse_page, :parent => citizenship, :title => "British citizenship")


    # When I visit the topics index
    visit mainstream_browse_pages_path

    # Then I should see the top-level topics in alphabetical order
    titles = page.all('.tags-list tbody td:first-child').map(&:text)
    expect(titles).to eq([
      'Citizenship',
      'Money and Tax',
    ])

    # When I visit a browse page page
    click_on "Citizenship"

    # Then I should see the child topics in alphabetical order
    child_titles = page.all('.children .tags-list tbody td:first-child').map(&:text)
    expect(child_titles).to eq([
      'British citizenship',
      'Voting',
    ])

  end

  it "Creating a page" do
    # When I fill out the details for a new mainstream browse page
    visit new_mainstream_browse_page_path

    fill_in 'Slug', :with => 'citizenship'
    fill_in 'Title', :with => 'Citizenship'
    fill_in 'Description', :with => 'Living in the UK'
    click_on 'Create'

    # Then the page should be created
    visit mainstream_browse_pages_path
    expect(page).to have_content('Citizenship')
    click_on('Citizenship')
    expect(page).to have_content('Living in the UK')

    # And the page should be in the "draft" state
    within '.attributes' do
      expect(page).to have_content('draft')
    end

    # And a draft should have been sent to publishing-api
    assert_publishing_api_put_draft_item('/browse/citizenship', {
      "title" => "Citizenship",
      "description" => "Living in the UK",
      "format" => "mainstream_browse_page",
    })

    # And the page should have been created in Panopticon
    assert_tag_created_in_panopticon(
      :tag_id => 'citizenship',
      :title => 'Citizenship',
      :description => 'Living in the UK',
      :tag_type => 'section',
    )
  end

  it "updating a draft page" do
    # Given a draft mainstream browse page exists
    create(:mainstream_browse_page, :draft, :slug => 'citizenship', :title => 'Citizenship')

    # When I make a change to the mainstream browse page
    visit mainstream_browse_pages_path
    click_on 'Citizenship'
    click_on 'Edit'

    fill_in 'Title', :with => 'Citizenship in the UK'
    fill_in 'Description', :with => 'Voting'
    click_on 'Save'

    # Then the page should be updated
    visit mainstream_browse_pages_path
    expect(page).to have_content('Citizenship in the UK')
    click_on('Citizenship in the UK')
    expect(page).to have_content('Voting')

    # And a draft should have been sent to publishing-api
    assert_publishing_api_put_draft_item('/browse/citizenship', {
      "title" => "Citizenship in the UK",
      "description" => "Voting",
      "format" => "mainstream_browse_page",
    })

    # And the page should have been updated in Panopticon
    assert_tag_updated_in_panopticon(
      :tag_type => 'section',
      :tag_id => 'citizenship',
      :title => 'Citizenship in the UK',
      :description => 'Voting',
    )
  end

  it "updating a published page" do
    # Given a published mainstream browse page exists
    create(:mainstream_browse_page, :published, :slug => 'citizenship', :title => 'Citizenship')

    # When I make a change to the mainstream browse page
    visit mainstream_browse_pages_path
    click_on 'Citizenship'
    click_on 'Edit'

    fill_in 'Title', :with => 'Citizenship in the UK'
    fill_in 'Description', :with => 'Voting'
    click_on 'Save'

    # Then the page should be updated
    visit mainstream_browse_pages_path
    expect(page).to have_content('Citizenship in the UK')

    # And a live item should have been sent to publishing-api
    assert_publishing_api_put_item('/browse/citizenship', {
      "title" => "Citizenship in the UK",
      "format" => "mainstream_browse_page",
    })

    # And the page should have been updated in Panopticon
    assert_tag_updated_in_panopticon(
      :tag_type => 'section',
      :tag_id => 'citizenship',
      :title => 'Citizenship in the UK',
      :description => 'Voting',
    )
  end

  it "updating a published page with invalid info" do
    # Given a published mainstream browse page exists
    create(:mainstream_browse_page, :published, :slug => 'citizenship', :title => 'Citizenship')

    # When I make a change to the mainstream browse page
    visit mainstream_browse_pages_path
    click_on 'Citizenship'
    click_on 'Edit'

    fill_in 'Title', with: ''
    fill_in 'Description', :with => 'A changed description'
    click_on 'Save'

    # Then I should see a proper error
    expect(page).to have_content("Title can't be blank")
    expect(find('#mainstream_browse_page_description').value).to eql "A changed description"
  end

  it "creating a child browse page" do
    # Given a draft mainstream browse page exists
    create(:mainstream_browse_page, :draft, :slug => 'citizenship', :title => 'Citizenship')

    # When I fill out the details for a new child browse page
    visit mainstream_browse_pages_path
    click_on 'Citizenship'
    click_on 'Add child page'

    fill_in 'Slug', :with => 'voting'
    fill_in 'Title', :with => 'Voting'
    fill_in 'Description', :with => 'Register to vote, postal voting forms'
    click_on 'Create'

    # Then the child page should be created
    visit mainstream_browse_pages_path
    click_on 'Citizenship'
    expect(page).to have_content('Voting')
    click_on 'Voting'
    expect(page).to have_content('Register to vote, postal voting forms')

    # And a draft should have been sent to publishing-api
    assert_publishing_api_put_draft_item('/browse/citizenship/voting', {
      "title" => "Voting",
      "description" => "Register to vote, postal voting forms",
      "format" => "mainstream_browse_page",
    })

    # And the child page should have been created in Panopticon
    assert_tag_created_in_panopticon(
      :tag_type => 'section',
      :tag_id => 'citizenship/voting',
      :title => 'Voting',
      :description => 'Register to vote, postal voting forms',
      :parent_id => 'citizenship',
    )
  end

  it "publishing a page" do
    # Given a draft mainstream browse page exists
    create(:mainstream_browse_page, :draft, :slug => 'citizenship', :title => 'Citizenship')

    # When I publish the browse page
    visit mainstream_browse_pages_path
    click_on 'Citizenship'
    click_on 'Publish mainstream browse page'

    # Then the page should be in the "published" state
    visit mainstream_browse_pages_path
    click_on('Citizenship')
    within '.attributes' do
      expect(page).to have_content('published')
    end

    # And a live item should have been sent to publishing-api
    assert_publishing_api_put_item('/browse/citizenship', {
      "title" => "Citizenship",
      "format" => "mainstream_browse_page",
    })

    # And the page should have been published in Panopticon
    assert_tag_published_in_panopticon(:tag_type => 'section', :tag_id => 'citizenship')
  end
end
