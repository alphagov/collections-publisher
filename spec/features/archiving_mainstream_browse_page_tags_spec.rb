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

  scenario "User archives published tag by redirecting to a path" do
    given_there_is_a_published_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    and_i_go_to_the_archive_page

    when_i_redirect_the_mainstream_browse_page_to_a_path
    then_i_see_the_confirmation_page_for_a_path_redirect
    when_i_confirm_the_archive
    then_the_tag_is_archived
  end

  scenario "User goes back from the confirmation page" do
    given_there_is_a_published_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    and_i_go_to_the_archive_page

    when_i_choose_a_successor_mainstream_browse_page
    and_i_click_continue
    and_i_click_back
    then_my_choices_are_preserved
    expect(@mainstream_browse_page.reload.archived?).to eql(false)
  end

  scenario "User continues without choosing a redirect" do
    given_there_is_a_published_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    and_i_go_to_the_archive_page

    and_i_click_continue
    then_i_see_an_error "Select where the page should redirect to"
  end

  scenario "User chooses to redirect to a browse page without selecting one" do
    given_there_is_a_published_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    and_i_go_to_the_archive_page

    choose "Another mainstream browse page"
    and_i_click_continue
    then_i_see_an_error "Select a mainstream browse page"
  end

  scenario "User archives draft tag" do
    given_there_is_a_draft_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    when_i_click_the_remove_button
    then_the_tag_is_deleted
    expect(page).to have_content "The mainstream browse page has been removed."
  end

  scenario "User tries to archive a page that is already archived" do
    given_there_is_a_published_mainstream_browse_page
    and_i_visit_the_mainstream_browse_page
    and_i_go_to_the_archive_page
    when_i_redirect_the_mainstream_browse_page_to_a_successor_mainstream_browse_page
    then_the_tag_is_archived

    when_i_submit_the_archive_request_again
    then_i_see_that_archived_mainstream_browse_pages_cannot_be_modified
    expect(page).to have_current_path(mainstream_browse_page_path(@mainstream_browse_page))
  end

  scenario "User tries to archive a top level page" do
    given_there_is_a_published_top_level_mainstream_browse_page

    when_i_submit_the_archive_request_for_it
    then_i_see_an_error "This mainstream browse page cannot be archived or removed"
    expect(@mainstream_browse_page.reload.published?).to eql(true)
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
    when_i_choose_a_successor_mainstream_browse_page
    and_i_click_continue
    expect(page).to have_title "Confirm archive"
    expect(page).to have_content "You’re about to archive ‘#{@mainstream_browse_page.title_including_parent}’."
    expect(page).to have_content "Users will be redirected to the mainstream browse page ‘The Successor Mainstream Browse Page’."
    when_i_confirm_the_archive
  end

  def when_i_choose_a_successor_mainstream_browse_page
    expect(page).to have_title "Where should ‘#{@mainstream_browse_page.title_including_parent}’ redirect to?"
    expect(page).to have_content "Archive mainstream browse page"
    expect(page).not_to have_content "Published"
    choose "Another mainstream browse page"
    select "The Successor Mainstream Browse Page", from: "Mainstream browse page"
  end

  def when_i_redirect_the_mainstream_browse_page_to_a_path
    stub_content_store_has_item("/existing-item")
    choose "A different type of GOV.UK page"
    fill_in "Page URL path", with: "/existing-item"
    and_i_click_continue
  end

  def then_i_see_the_confirmation_page_for_a_path_redirect
    expect(page).to have_content "Users will be redirected to: ‘/existing-item’"
  end

  def and_i_click_continue
    click_button "Continue"
  end

  def and_i_click_back
    click_link "Back"
  end

  def when_i_confirm_the_archive
    click_button "Archive mainstream browse page"
  end

  def then_my_choices_are_preserved
    expect(find_field("Another mainstream browse page")).to be_checked
    expect(find_field("Mainstream browse page").value).to eq MainstreamBrowsePage.find_by(title: "The Successor Mainstream Browse Page").id.to_s
  end

  def then_i_see_an_error(message)
    expect(page).to have_content message
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

  def given_there_is_a_published_top_level_mainstream_browse_page
    @mainstream_browse_page = create(:mainstream_browse_page, :published, slug: "top-level")
  end

  def when_i_submit_the_archive_request_again
    when_i_submit_the_archive_request_for_it
  end

  def when_i_submit_the_archive_request_for_it
    successor = MainstreamBrowsePage.find_by!(title: "The Successor Mainstream Browse Page")
    page.driver.submit :post,
                       archive_mainstream_browse_page_path(@mainstream_browse_page),
                       mainstream_browse_page_archival_form: { redirect_type: "browse_page", successor: successor.id }
  end

  def and_there_is_a_mainstream_browse_page_that_can_be_used_as_a_replacement
    create(:mainstream_browse_page, :published, title: "The Successor Mainstream Browse Page")
  end

  def when_i_click_the_remove_button
    click_link "Delete page"
  end

  def and_i_go_to_the_archive_page
    click_link "Archive mainstream browse page"
  end

  def then_the_tag_is_archived
    expect(@mainstream_browse_page.reload.archived?).to eql(true)
    expect(page).to have_content "The mainstream browse page has been archived."
  end

  def then_i_see_that_i_cannot_edit_the_page
    expect(page).to have_content "You cannot modify an archived mainstream browse page."
  end

  def when_i_submit_an_invalid_base_path_as_redirect
    stub_content_store_does_not_have_item("/not-here")
    choose "A different type of GOV.UK page"
    fill_in "Page URL path", with: "/not-here"
    and_i_click_continue
  end

  def then_i_see_that_the_url_isnt_valid
    expect(page).to have_content("This URL isn’t a valid target for a redirect on GOV.UK")
  end
end
