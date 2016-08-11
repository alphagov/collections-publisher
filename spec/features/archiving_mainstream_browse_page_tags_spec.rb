require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.feature "Archiving mainstream browse page tags" do
  include PublishingApiHelpers
  include CommonFeatureSteps
  include GdsApi::TestHelpers::ContentStore

  before do
    # Stub rummager so that mainstream browse pages do not have links.
    stub_any_call_to_rummager_with_documents([])

    stub_any_publishing_api_call

    @rummager_deletion = stub_request(:delete, %r[#{Plek.find('rummager')}/*]).to_return(body: "{}")
    @panopticon_deletion = stub_request(:delete, %r[#{Plek.find('panopticon')}/*]).to_return(body: "{}")

    # Background
    given_I_am_a_GDS_editor
    and_there_is_a_mainstream_browse_page_that_can_be_used_as_a_replacement
  end

  scenario "User visits an archived tag" do
    given_there_is_an_archived_mainstream_browse_page
    when_I_visit_the_mainstream_browse_page_edit_page
    then_I_see_that_archived_mainstream_browse_pages_cannot_be_modified
  end

  scenario "User archives published tag" do
    given_there_is_a_published_mainstream_browse_page
    and_I_visit_the_mainstream_browse_page
    and_I_go_to_the_archive_page

    when_I_redirect_the_mainstream_browse_page_to_a_successor_mainstream_browse_page
    then_the_tag_is_archived
    and_the_tag_is_removed_from_search
    and_the_tag_is_removed_from_panopticon

    when_I_visit_the_mainstream_browse_page_edit_page
    then_I_see_that_I_cannot_edit_the_page
  end

  scenario "User attempts to archive tag with incoming links" do
    given_there_is_a_published_mainstream_browse_page
    and_the_mainstream_browse_page_has_content_tagged_to_it
    and_I_visit_the_mainstream_browse_page
    and_I_go_to_the_archive_page
    when_I_redirect_the_mainstream_browse_page_to_a_successor_mainstream_browse_page
    then_I_see_that_archiving_is_impossible_because_there_is_content_tagged
  end

  scenario "User archives draft tag" do
    given_there_is_a_draft_mainstream_browse_page
    and_I_visit_the_mainstream_browse_page
    when_I_click_the_remove_button
    then_the_tag_is_deleted
    and_the_tag_is_removed_from_panopticon
  end

  scenario "User redirects to invalid basepath" do
    given_there_is_a_published_mainstream_browse_page
    and_I_visit_the_mainstream_browse_page
    and_I_go_to_the_archive_page
    when_I_submit_an_invalid_base_path_as_redirect
    then_I_see_that_the_URL_isnt_valid
  end

  def then_the_tag_is_deleted
    expect { @mainstream_browse_page.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def when_I_redirect_the_mainstream_browse_page_to_a_successor_mainstream_browse_page
    select 'The Successor Mainstream Browse Page', from: "mainstream_browse_page_archival_form_successor"
    click_button 'Archive and redirect to a mainstream browse page'
  end

  def when_I_visit_the_mainstream_browse_page_edit_page
    visit edit_mainstream_browse_page_path(@mainstream_browse_page)
  end

  def and_I_visit_the_mainstream_browse_page
    visit mainstream_browse_page_path(@mainstream_browse_page)
  end

  def then_I_see_that_archived_mainstream_browse_pages_cannot_be_modified
    expect(page).to have_content 'You cannot modify an archived mainstream browse page.'
  end

  def given_there_is_an_archived_mainstream_browse_page
    @mainstream_browse_page = create(:mainstream_browse_page, :archived)
  end

  def given_there_is_a_published_mainstream_browse_page
    @mainstream_browse_page = create(:mainstream_browse_page, :published, slug: 'bar', parent: create(:mainstream_browse_page, slug: 'foo'))
  end

  def given_there_is_a_draft_mainstream_browse_page
    @mainstream_browse_page = create(:mainstream_browse_page, :draft, slug: 'bar', parent: create(:mainstream_browse_page, slug: 'foo'))
  end

  def and_there_is_a_mainstream_browse_page_that_can_be_used_as_a_replacement
    create(:mainstream_browse_page, :published, title: 'The Successor Mainstream Browse Page')
  end

  def when_I_click_the_remove_button
    click_link 'Remove mainstream browse page'
  end

  def and_I_go_to_the_archive_page
    click_link 'Archive mainstream browse page'
  end

  def and_the_mainstream_browse_page_has_content_tagged_to_it
    stub_request(:delete, "https://panopticon.test.gov.uk/tags/section/foo/bar.json")
      .to_return(status: 409, body: "{}")
  end

  def then_I_see_that_archiving_is_impossible_because_there_is_content_tagged
    expect(page).to have_content 'The tag could not be deleted because there are documents tagged to it'
  end

  def and_the_tag_is_removed_from_panopticon
    expect(@panopticon_deletion).to have_been_requested
  end

  def then_the_tag_is_archived
    expect(@mainstream_browse_page.reload.archived?).to eql(true)
  end

  def and_the_tag_is_removed_from_search
    expect(@rummager_deletion).to have_been_requested
  end

  def then_I_see_that_I_cannot_edit_the_page
    expect(page).to have_content 'You cannot modify an archived mainstream browse page.'
  end

  def when_I_submit_an_invalid_base_path_as_redirect
    content_store_does_not_have_item('/not-here')
    fill_in "mainstream_browse_page_archival_form[successor_path]", with: '/not-here'
    click_button "Archive and redirect to a page"
  end

  def then_I_see_that_the_URL_isnt_valid
    expect(page).to have_content("This URL isn't a valid target for a redirect on GOV.UK.")
  end
end
