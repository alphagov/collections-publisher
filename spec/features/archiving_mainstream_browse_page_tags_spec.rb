require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.feature "Archiving mainstream browse page tags" do
  include CommonFeatureSteps
  include GdsApi::TestHelpers::ContentStore

  before do
    stub_any_publishing_api_call
    publishing_api_has_no_linked_items

    # Background
    given_i_am_a_gds_editor
    and_there_is_a_mainstream_browse_page_that_can_be_used_as_a_replacement
  end

  scenario "User visits an archived tag" do
    given_there_is_an_archived_mainstream_browse_page
    when_i_visit_the_mainstream_browse_page_edit_page
    then_i_see_that_archived_mainstream_browse_pages_cannot_be_modified
  end

  scenario "User archives published tag" do
    given_there_is_a_published_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    and_i_go_to_the_archive_page

    when_i_redirect_the_mainstream_browse_page_to_a_successor_mainstream_browse_page
    then_the_tag_is_archived
    when_i_visit_the_mainstream_browse_page_edit_page
    then_i_see_that_i_cannot_edit_the_page
  end

  scenario "User archives draft tag" do
    given_there_is_a_draft_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    when_i_click_the_remove_button
    then_the_tag_is_deleted
  end

  scenario "User redirects to invalid basepath" do
    given_there_is_a_published_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    and_i_go_to_the_archive_page
    when_i_submit_an_invalid_base_path_as_redirect
    then_i_see_that_the_url_isnt_valid
  end

  def then_the_tag_is_deleted
    expect { @mainstream_browse_page.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def when_i_redirect_the_mainstream_browse_page_to_a_successor_mainstream_browse_page
    select "The Successor Mainstream Browse Page", from: "mainstream_browse_page_archival_form_successor"
    click_button "Archive and redirect to a mainstream browse page"
  end

  def when_i_visit_the_mainstream_browse_page_edit_page
    visit edit_mainstream_browse_page_path(@mainstream_browse_page)
  end

  def and_i_visit_the_mainstream_browse_page
    visit mainstream_browse_page_path(@mainstream_browse_page)
  end

  def then_i_see_that_archived_mainstream_browse_pages_cannot_be_modified
    expect(page).to have_content "You cannot modify an archived mainstream browse page."
  end

  def given_there_is_an_archived_mainstream_browse_page
    @mainstream_browse_page = create(:mainstream_browse_page, :archived)
  end

  def given_there_is_a_published_mainstream_browse_page
    @mainstream_browse_page = create(:mainstream_browse_page, :published, slug: "bar", parent: create(:mainstream_browse_page, slug: "foo"))
  end

  def given_there_is_a_draft_mainstream_browse_page
    @mainstream_browse_page = create(:mainstream_browse_page, :draft, slug: "bar", parent: create(:mainstream_browse_page, slug: "foo"))
  end

  def and_there_is_a_mainstream_browse_page_that_can_be_used_as_a_replacement
    create(:mainstream_browse_page, :published, title: "The Successor Mainstream Browse Page")
  end

  def when_i_click_the_remove_button
    click_link "Remove mainstream browse page"
  end

  def and_i_go_to_the_archive_page
    click_link "Archive mainstream browse page"
  end

  def then_the_tag_is_archived
    expect(@mainstream_browse_page.reload.archived?).to eql(true)
  end

  def then_i_see_that_i_cannot_edit_the_page
    expect(page).to have_content "You cannot modify an archived mainstream browse page."
  end

  def when_i_submit_an_invalid_base_path_as_redirect
    stub_content_store_does_not_have_item("/not-here")
    fill_in "mainstream_browse_page_archival_form[successor_path]", with: "/not-here"
    click_button "Archive and redirect to a page"
  end

  def then_i_see_that_the_url_isnt_valid
    expect(page).to have_content("This URL isn't a valid target for a redirect on GOV.UK.")
  end
end
