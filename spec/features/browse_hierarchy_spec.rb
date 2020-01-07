require "rails_helper"

RSpec.feature "Browse hierarchy" do
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_i_am_a_gds_editor
    and_external_services_are_stubbed
  end

  scenario "User creates a top-level browse page" do
    given_there_is_a_browse_page_with_a_child_page
    when_i_create_a_new_top_level_page
    and_i_visit_the_browse_pages_index
    then_i_can_see_that_the_new_parent_page_is_created
    and_the_newly_created_page_is_sent_to_the_publishing_api_as_draft
    and_the_parent_page_is_sent_to_the_publishing_api
    and_the_child_page_is_sent_to_the_publishing_api
  end

  scenario "User creates a child page" do
    given_there_is_a_browse_page_with_a_child_page
    when_i_create_a_child_page
    and_i_visit_the_browse_pages_index
    then_i_can_see_that_the_new_child_page_is_created
    and_the_newly_created_page_is_sent_to_the_publishing_api_as_draft
    and_the_parent_page_is_sent_to_the_publishing_api
    and_the_child_page_is_sent_to_the_publishing_api
  end

  def given_there_is_a_browse_page_with_a_child_page
    @parent = create(:mainstream_browse_page, :published, slug: "citizenship", title: "Citizenship")
    @child = create(:mainstream_browse_page, :published, parent: @parent, slug: "voting")
  end

  def then_i_can_see_that_the_new_child_page_is_created
    click_on "Citizenship"
    expect(page).to have_content("Benefits")

    click_on "Benefits"
    expect(page).to have_content("Benefits description.")
  end

  def then_i_can_see_that_the_new_parent_page_is_created
    expect(page).to have_content("Benefits")
    click_on "Benefits"
    expect(page).to have_content("Benefits description.")
  end

  def when_i_create_a_new_top_level_page
    visit mainstream_browse_pages_path
    click_on "Add a mainstream browse page"
    fill_in_browse_form
  end

  def when_i_create_a_child_page
    visit mainstream_browse_pages_path
    click_on "Citizenship"
    click_on "Add child page"
    fill_in_browse_form
  end

  def fill_in_browse_form
    fill_in "Slug", with: "benefits"
    fill_in "Title", with: "Benefits"
    fill_in "Description", with: "Benefits description."
    click_on "Create"

    @content_id = extract_content_id_from(current_path)
  end

  def and_the_newly_created_page_is_sent_to_the_publishing_api_as_draft
    assert_publishing_api_put_content(@content_id)
    assert_publishing_api_patch_links(@content_id)
    assert_publishing_api_not_published(@content_id)
  end

  def and_the_parent_page_is_sent_to_the_publishing_api
    assert_publishing_api_put_content(@parent.content_id)
    assert_publishing_api_patch_links(@parent.content_id)
    assert_publishing_api_publish(@parent.content_id)
  end

  def and_the_child_page_is_sent_to_the_publishing_api
    assert_publishing_api_put_content(@child.content_id)
    assert_publishing_api_patch_links(@child.content_id)
    assert_publishing_api_publish(@child.content_id)
  end
end
