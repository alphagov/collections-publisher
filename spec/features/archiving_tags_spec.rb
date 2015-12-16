require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.feature "Archiving tags" do
  include PublishingApiHelpers
  include CommonFeatureSteps
  include GdsApi::TestHelpers::ContentStore

  before do
    # Stub rummager so that topics do not have links.
    stub_any_call_to_rummager_with_documents([])

    stub_put_content_to_publishing_api
    stub_publish_to_publishing_api

    @rummager_deletion = stub_request(:delete, %r[#{Plek.find('rummager')}/*]).to_return(body: "{}")
    @panopticon_deletion = stub_request(:delete, %r[#{Plek.find('panopticon')}/*]).to_return(body: "{}")

    # Background
    given_I_am_a_GDS_editor
    and_there_is_a_topic_that_can_be_used_as_a_replacement
  end

  scenario "User visits an archived tag" do
    given_there_is_an_archived_topic
    when_I_visit_the_topic_edit_page
    then_I_see_that_archived_topics_cannot_be_modified
  end

  scenario "User archives published tag" do
    given_there_is_a_published_topic
    and_I_visit_the_topic
    and_I_go_to_the_archive_page

    when_I_redirect_the_topic_to_a_successor_topic
    then_the_tag_is_archived
    and_the_tag_is_removed_from_search
    and_the_tag_is_removed_from_panopticon

    when_I_visit_the_topic_edit_page
    then_I_see_that_I_cannot_edit_the_page
  end

  scenario "User attempts to archive tag with incoming links" do
    given_there_is_a_published_topic
    and_the_topic_has_content_tagged_to_it
    and_I_visit_the_topic
    and_I_go_to_the_archive_page
    when_I_redirect_the_topic_to_a_successor_topic
    then_I_see_that_archiving_is_impossible_because_there_is_content_tagged
  end

  scenario "User archives draft tag" do
    given_there_is_a_draft_topic
    and_I_visit_the_topic
    when_I_click_the_remove_button
    then_the_tag_is_deleted
    and_the_tag_is_removed_from_panopticon
  end

  scenario "User redirects to invalid basepath" do
    given_there_is_a_published_topic
    and_I_visit_the_topic
    and_I_go_to_the_archive_page
    when_I_submit_an_invalid_base_path_as_redirect
    then_I_see_that_the_URL_isnt_valid
  end

  def then_the_tag_is_deleted
    expect { @topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def when_I_redirect_the_topic_to_a_successor_topic
    select 'The Successor Topic', from: "archival_form_successor"
    click_button 'Archive and redirect to a topic'
  end

  def when_I_visit_the_topic_edit_page
    visit edit_topic_path(@topic)
  end

  def and_I_visit_the_topic
    visit topic_path(@topic)
  end

  def then_I_see_that_archived_topics_cannot_be_modified
    expect(page).to have_content 'You cannot modify an archived topic.'
  end

  def given_there_is_an_archived_topic
    @topic = create(:topic, :archived)
  end

  def given_there_is_a_published_topic
    @topic = create(:topic, :published, slug: 'bar', parent: create(:topic, slug: 'foo'))
  end

  def given_there_is_a_draft_topic
    @topic = create(:topic, :draft, slug: 'bar', parent: create(:topic, slug: 'foo'))
  end

  def and_there_is_a_topic_that_can_be_used_as_a_replacement
    create(:topic, :published, title: 'The Successor Topic')
  end

  def when_I_click_the_remove_button
    click_link 'Remove topic'
  end

  def and_I_go_to_the_archive_page
    click_link 'Archive topic'
  end

  def and_the_topic_has_content_tagged_to_it
    stub_request(:delete, "https://panopticon.test.gov.uk/tags/specialist_sector/foo/bar.json")
      .to_return(status: 409, body: "{}")
  end

  def then_I_see_that_archiving_is_impossible_because_there_is_content_tagged
    expect(page).to have_content 'The tag could not be deleted because there are documents tagged to it'
  end

  def and_the_tag_is_removed_from_panopticon
    expect(@panopticon_deletion).to have_been_requested
  end

  def then_the_tag_is_archived
    expect(@topic.reload.archived?).to eql(true)
  end

  def and_the_tag_is_removed_from_search
    expect(@rummager_deletion).to have_been_requested
  end

  def then_I_see_that_I_cannot_edit_the_page
    expect(page).to have_content 'You cannot modify an archived topic.'
  end

  def when_I_submit_an_invalid_base_path_as_redirect
    content_store_does_not_have_item('/not-here')
    fill_in "archival_form[successor_path]", with: '/not-here'
    click_button "Archive and redirect to a page"
  end

  def then_I_see_that_the_URL_isnt_valid
    expect(page).to have_content("This URL isn't a valid target for a redirect on GOV.UK.")
  end
end
