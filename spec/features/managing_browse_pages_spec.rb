require "rails_helper"

RSpec.feature "Managing browse pages" do
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_i_am_a_gds_editor
    and_external_services_are_stubbed
  end

  scenario "User creates, edits and publishes page" do
    when_i_visit_the_new_browse_page_form
    and_i_fill_in_the_form
    and_i_visit_the_browse_pages_index
    then_i_see_my_newly_created_page
    when_i_click_on_my_new_page
    then_i_see_that_the_page_is_in_draft
    and_the_draft_is_sent_to_the_publishing_pipeline

    when_i_navigate_to_the_edit_page
    and_i_submit_a_changed_description
    then_i_see_that_the_description_has_changed
    and_the_updated_item_is_sent_to_the_publishing_pipeline

    when_i_click_on_the_publish_button
    then_i_see_that_the_page_is_published
    and_the_page_has_been_published_in_the_pipeline
  end

  scenario "User updates published page" do
    given_there_is_published_browse_page
    when_i_visit_the_edit_browse_page_page
    when_i_update_the_browse_page
    then_i_see_that_the_page_is_updated
    and_the_published_data_is_sent_to_the_publishing_pipeline
  end

  scenario "Validation fails" do
    when_i_visit_the_new_browse_page_form
    and_i_fill_in_the_form_with_invalid_data
    then_i_see_a_validation_error
  end

  def given_there_is_published_browse_page
    @page = create(:mainstream_browse_page, :published, slug: "citizenship", title: "Citizenship")
  end

  def when_i_visit_the_edit_browse_page_page
    visit edit_mainstream_browse_page_path(@page)
  end

  def when_i_update_the_browse_page
    fill_in "Title", with: "Citizenship in the UK"
    fill_in "Description", with: "Voting"
    click_on "Save"
  end

  def then_i_see_that_the_page_is_updated
    visit mainstream_browse_pages_path
    expect(page).to have_content("Citizenship in the UK")
  end

  def when_i_click_on_the_publish_button
    click_on "Publish mainstream browse page"
  end

  def when_i_navigate_to_the_edit_page
    click_on "Edit page"
  end

  def and_i_submit_a_changed_description
    fill_in "Description", with: "A new description"
    click_on "Save"
  end

  def then_i_see_that_the_description_has_changed
    expect(page).to have_content("A new description")
  end

  def then_i_see_my_newly_created_page
    expect(page).to have_content("Citizenship")
  end

  def and_i_fill_in_the_form
    fill_in "Slug", with: "citizenship"
    fill_in "Title", with: "Citizenship"
    fill_in "Description", with: "Living in the UK"
    click_on "Create"
    @content_id = extract_content_id_from(current_path)
  end

  def and_i_fill_in_the_form_with_invalid_data
    fill_in "Title", with: ""
    fill_in "Description", with: "A changed description"
    click_on "Create"
  end

  def when_i_click_on_my_new_page
    click_on("Citizenship")
  end

  def then_i_see_that_the_page_is_in_draft
    within ".attributes" do
      expect(page).to have_content("draft")
    end
  end

  def then_i_see_that_the_page_is_published
    within ".attributes" do
      expect(page).to have_content("published")
    end
  end

  def and_the_page_has_been_published_in_the_pipeline
    assert_publishing_api_publish(@content_id)
  end

  def and_the_draft_is_sent_to_the_publishing_pipeline
    assert_publishing_api_put_content(
      @content_id,
      request_json_includes(
        title: "Citizenship",
        description: "Living in the UK",
        document_type: "mainstream_browse_page",
        schema_name: "mainstream_browse_page",
      ),
    )

    assert_publishing_api_patch_links(@content_id)

    assert_publishing_api_not_published(@content_id)
  end

  def and_the_published_data_is_sent_to_the_publishing_pipeline
    assert_publishing_api_put_content(
      @page.content_id,
      request_json_includes(
        title: "Citizenship in the UK",
        document_type: "mainstream_browse_page",
      ),
    )

    assert_publishing_api_patch_links(@page.content_id)

    assert_publishing_api_publish(@page.content_id)
  end

  def and_the_updated_item_is_sent_to_the_publishing_pipeline
    assert_publishing_api_put_content(
      @content_id,
      request_json_includes(
        description: "A new description",
      ),
    )
  end

  def then_i_see_a_validation_error
    expect(page).to have_content("Title can't be blank")
    expect(find("#mainstream_browse_page_description").value).to eql "A changed description"
  end
end
