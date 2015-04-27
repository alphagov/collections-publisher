require 'spec_helper'

RSpec.describe "creating and editing topics" do

  before :each do
    stub_user.permissions << "GDS Editor"
    stub_default_publishing_api_put
    stub_default_publishing_api_put_draft
    stub_all_panopticon_tag_calls
  end

  it "Creating a topic" do
    # When I fill out the details for a topic
    visit new_topic_path

    fill_in 'Slug', :with => 'working-at-sea'
    fill_in 'Title', :with => 'Working at sea'
    fill_in 'Description', :with => 'The sea, the sky, the sea, the sky...'
    click_on 'Create'

    # Then the topic should be created
    visit topics_path
    expect(page).to have_content('Working at sea')
    click_on('Working at sea')
    expect(page).to have_content('The sea, the sky, the sea, the sky...')

    # And the topic should be in the "draft" state
    within '.attributes' do
      expect(page).to have_content('draft')
    end

    # And a draft should have been sent to publishing-api (pending)
    #assert_publishing_api_put_draft_item('/working-at-sea', {
      #"title" => "Working at sea",
      #"description" => 'The sea, the sky, the sea, the sky...',
      #"format" => "topic",
    #})

    # And the topic should have been created in Panopticon
    assert_tag_created_in_panopticon(
      :tag_id => 'working-at-sea',
      :title => 'Working at sea',
      :description => 'The sea, the sky, the sea, the sky...',
      :tag_type => 'specialist_sector',
    )
  end

  it "updating a draft page" do
    # Given a draft topic exists
    create(:topic, :draft, :slug => 'working-at-sea', :title => 'Working at sea')

    # When I make a change to the topic
    visit topics_path
    click_on 'Working at sea'
    click_on 'Edit'

    fill_in 'Title', :with => 'Working on the ocean'
    fill_in 'Description', :with => 'I woke up one morning, The sea was still there.'
    click_on 'Save'

    # Then the topic should be updated
    visit topics_path
    expect(page).to have_content('Working on the ocean')
    click_on('Working on the ocean')
    expect(page).to have_content('I woke up one morning, The sea was still there.')

    # And a draft should have been sent to publishing-api (pending)
    #assert_publishing_api_put_draft_item('/working-at-sea', {
      #"title" => "Working on the ocean",
      #"description" => "I woke up one morning, The sea was still there.",
      #"format" => "topic",
    #})

    # And the topic should have been updated in Panopticon
    assert_tag_updated_in_panopticon(
      :tag_type => 'specialist_sector',
      :tag_id => 'working-at-sea',
      :title => 'Working on the ocean',
      :description => 'I woke up one morning, The sea was still there.',
    )
  end

  it "updating a published page" do
    # Given a published topic exists
    create(:topic, :published, :slug => 'working-at-sea', :title => 'Working at sea')

    # When I make a change to the topic
    visit topics_path
    click_on 'Working at sea'
    click_on 'Edit'

    fill_in 'Title', :with => 'Working on the ocean'
    fill_in 'Description', :with => 'I woke up one morning, The sea was still there.'
    click_on 'Save'

    # Then the topic should be updated
    visit topics_path
    expect(page).to have_content('Working on the ocean')

    # And a live item should have been sent to publishing-api
    assert_publishing_api_put_item('/working-at-sea', {
      "title" => 'Working on the ocean',
      "description" => "I woke up one morning, The sea was still there.",
      "format" => "topic",
    })

    # And the topic should have been updated in Panopticon
    assert_tag_updated_in_panopticon(
      :tag_type => 'specialist_sector',
      :tag_id => 'working-at-sea',
      :title => 'Working on the ocean',
      :description => 'I woke up one morning, The sea was still there.',
    )
  end

  it "creating a child topic" do
    # Given a draft topic exists
    create(:topic, :draft, :slug => 'working-at-sea', :title => 'Working at sea')

    # When I fill out the details for a new child topic
    visit topics_path
    click_on 'Working at sea'
    click_on 'Add child page'

    fill_in 'Slug', :with => 'desert-islands'
    fill_in 'Title', :with => 'Desert Islands'
    fill_in 'Description', :with => 'Remember your cheese...'
    click_on 'Create'

    # Then the child topic should be created
    visit topics_path
    click_on 'Working at sea'
    expect(page).to have_content('Desert Islands')
    click_on 'Desert Islands'
    expect(page).to have_content('Remember your cheese...')

    # And a draft should have been sent to publishing-api (pending)
    #assert_publishing_api_put_draft_item('/working-at-sea/desert-islands', {
      #"title" => 'Desert Islands',
      #"description" => 'Remember your cheese...',
      #"format" => 'topic',
    #})

    # And the child topic should have been created in Panopticon
    assert_tag_created_in_panopticon(
      :tag_type => 'specialist_sector',
      :tag_id => 'working-at-sea/desert-islands',
      :title => 'Desert Islands',
      :description => 'Remember your cheese...',
      :parent_id => 'working-at-sea',
    )
  end

  it "publishing a topic" do
    # Given a draft topic exists
    create(:topic, :draft, :slug => 'working-at-sea', :title => 'Working at sea')

    # When I publish the topic
    visit topics_path
    click_on 'Working at sea'
    click_on 'Publish topic'

    # Then the topic should be in the "published" state
    visit topics_path
    click_on('Working at sea')
    within '.attributes' do
      expect(page).to have_content('published')
    end

    # And a live item should have been sent to publishing-api
    assert_publishing_api_put_item('/working-at-sea', {
      "title" => "Working at sea",
      "format" => "topic",
    })

    # And the topic should have been published in Panopticon
    assert_tag_published_in_panopticon(:tag_type => 'specialist_sector', :tag_id => 'working-at-sea')
  end
end
