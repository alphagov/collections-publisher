require 'rails_helper'

RSpec.describe "creating and editing topics" do
  before :each do
    stub_user.permissions << "GDS Editor"
    stub_all_panopticon_tag_calls
    stub_rummager_linked_content_call
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

    # And a draft should have been sent to publishing-api
    assert_publishing_api_put_draft_item('/topic/working-at-sea', {
      "title" => "Working at sea",
      "description" => 'The sea, the sky, the sea, the sky...',
      "format" => "topic",
    })

    # And the topic should have been created in Panopticon
    assert_tag_created_in_panopticon(
      :tag_id => 'working-at-sea',
      :title => 'Working at sea',
      :description => 'The sea, the sky, the sea, the sky...',
      :tag_type => 'specialist_sector',
    )
  end

  it "Creating an invalid topic" do
    # When I visit the new topic path
    visit new_topic_path

    # And I fill in invalid info
    fill_in 'Slug', with: ''
    click_on 'Create'

    # Then I should see a validation error
    expect(page).to have_content("Slug can't be blank")
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

    # And a draft should have been sent to publishing-api
    assert_publishing_api_put_draft_item('/topic/working-at-sea', {
      "title" => "Working on the ocean",
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

  it "updating a published page" do
    stub_request(:post, %r[.rummager]).to_return(body: JSON.dump({}))

    # Given a published topic exists
    create(:topic, :published, :slug => 'working-at-sea', :title => 'Working at sea')

    # When I make a change to the topic
    visit topics_path
    click_on 'Working at sea'
    click_on 'Edit'

    fill_in 'Title', :with => 'Working on the ocean'
    fill_in 'Description', :with => 'I woke up one morning, The sea was still there.'
    check 'Beta'
    click_on 'Save'

    # Then the topic should be updated
    visit topics_path
    expect(page).to have_content('Working on the ocean')
    expect(page).to have_content('In Beta')

    # And a live item should have been sent to publishing-api
    assert_publishing_api_put_item('/topic/working-at-sea', {
      "title" => 'Working on the ocean',
      "description" => "I woke up one morning, The sea was still there.",
      "format" => "topic",
      "phase" => "beta",
      "details" => {
        "groups" => [],
        "beta" => true,
      }
    })

    # And the topic should have been updated in Panopticon
    assert_tag_updated_in_panopticon(
      :tag_type => 'specialist_sector',
      :tag_id => 'working-at-sea',
      :title => 'Working on the ocean',
      :description => 'I woke up one morning, The sea was still there.',
    )

    # And rummager should have been updated
    assert_rummager_posted_item(
      {
        format: "specialist_sector",
        title: "Working on the ocean",
        description: "I woke up one morning, The sea was still there.",
        link: "/topic/working-at-sea",
        "_type" => "edition",
        "_id" => "/topic/working-at-sea",
      }
    )
  end

  it "updating a published topic with invalid info" do
    # Given a published topic exists
    create(:topic, :published, :slug => 'working-at-sea', :title => 'Working at sea')

    # When I make a change to the topic
    visit topics_path
    click_on 'Working at sea'
    click_on 'Edit'

    fill_in 'Title', with: ''
    click_on 'Save'

    expect(page).to have_content("Title can't be blank")
  end

  it "creating a child topic" do
    # Given a draft topic exists
    topic = create(:topic, :draft, :slug => 'working-at-sea', :title => 'Working at sea')
    create(:redirect, tag: topic)

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

    # And a draft should have been sent to publishing-api
    assert_publishing_api_put_draft_item('/topic/working-at-sea/desert-islands', {
      "title" => 'Desert Islands',
      "description" => 'Remember your cheese...',
      "format" => 'topic',
    })
    # And its parent should have been sent to publishing-api
    assert_publishing_api_put_draft_item('/topic/working-at-sea')

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
    stub_request(:post, %r[.rummager]).to_return(body: JSON.dump({}))

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
    assert_publishing_api_put_item('/topic/working-at-sea', {
      "title" => "Working at sea",
      "format" => "topic",
    })

    # And the topic should have been published in Panopticon
    assert_tag_published_in_panopticon(:tag_type => 'specialist_sector', :tag_id => 'working-at-sea')

    # And rummager should have been updated
    assert_rummager_posted_item(
      {
        format: "specialist_sector",
        title: "Working at sea",
        description: "Example description",
        link: "/topic/working-at-sea",
        "_type" => "edition",
        "_id" => "/topic/working-at-sea",
      }
    )
  end

  it "updating a topic that has unpublished lists" do
    # Stub the call to rummager, we don't care about that now.
    stub_request(:post, %r[.rummager]).to_return(body: JSON.dump({}))

    # Given there is a topic with unpublished lists that never has been published
    topic = create(:topic, :published, dirty: true, slug: 'working-at-sea', title: 'Working at sea')
    create(:list, name: 'Some Superlist', tag: topic)

    # When I make a change to the topic
    visit edit_topic_path(topic)

    fill_in 'Title', :with => 'Working on the ocean'
    click_on 'Save'

    # And a live item should have been sent to publishing-api
    assert_publishing_api_put_item('/topic/working-at-sea', {
      "details" => {
        "groups" => [],
        "beta" => false,
      }
    })
  end


  def assert_rummager_posted_item(attributes)
    url = Plek.new.find('rummager') + "/documents"
    assert_requested(:post, url) do |req|
      data = JSON.parse(req.body)
      attributes.to_a.all? do |key, value|
        data[key.to_s] == value
      end
    end
  end
end
