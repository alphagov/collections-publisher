require "rails_helper"

RSpec.feature "Managing topics" do
  include PublishingApiHelpers
  include CommonFeatureSteps
  include NavigationSteps

  before do
    given_I_am_a_GDS_editor
    and_external_services_are_stubbed
  end

  scenario "User creates, edits and publishes page" do
    when_I_visit_the_new_topic_form
    and_I_fill_in_the_form
    and_I_visit_the_topics_index
    then_I_see_my_newly_created_page
    when_I_click_on_my_new_page
    then_I_see_that_the_page_is_in_draft
    and_the_draft_is_sent_to_the_publishing_pipeline

    when_I_navigate_to_the_edit_page
    and_I_submit_a_changed_description
    then_I_see_that_the_description_has_changed
    and_the_updated_item_is_sent_to_the_publishing_pipeline

    when_I_click_on_the_publish_button
    then_I_see_that_the_page_is_published
    and_the_page_has_been_published_in_the_pipeline
  end

  scenario "User updates published page" do
    given_there_is_published_topic
    when_I_visit_the_edit_topic_page
    when_I_update_the_topic
    then_I_see_that_the_page_is_updated
    and_the_published_data_is_sent_to_the_publishing_pipeline
  end

  scenario "Validation fails" do
    when_I_visit_the_new_topic_form
    and_I_fill_in_the_form_with_invalid_data
    then_I_see_a_validation_error
  end

  def given_there_is_published_topic
    @page = create(:topic, :published, slug: "citizenship", title: "Citizenship")
  end

  def when_I_visit_the_edit_topic_page
    visit edit_topic_path(@page)
  end

  def when_I_update_the_topic
    fill_in "Title", with: "Citizenship in the UK"
    fill_in "Description", with: "Voting"
    click_on "Save"
  end

  def then_I_see_that_the_page_is_updated
    visit topics_path
    expect(page).to have_content("Citizenship in the UK")
  end

  def when_I_click_on_the_publish_button
    click_on "Publish topic"
  end

  def when_I_navigate_to_the_edit_page
    click_on "Edit topic"
  end

  def and_I_submit_a_changed_description
    fill_in "Description", with: "A new description"
    click_on "Save"
  end

  def then_I_see_that_the_description_has_changed
    expect(page).to have_content("A new description")
  end

  def then_I_see_my_newly_created_page
    expect(page).to have_content("Citizenship")
  end

  def and_I_fill_in_the_form
    fill_in "Slug", with: "citizenship"
    fill_in "Title", with: "Citizenship"
    fill_in "Description", with: "Living in the UK"
    click_on "Create"
    @content_id = extract_content_id_from(current_path)
  end

  def and_I_fill_in_the_form_with_invalid_data
    fill_in "Title", with: ""
    fill_in "Description", with: "A changed description"
    click_on "Create"
  end

  def when_I_click_on_my_new_page
    click_on("Citizenship")
  end

  def then_I_see_that_the_page_is_in_draft
    within ".attributes" do
      expect(page).to have_content("draft")
    end
  end

  def then_I_see_that_the_page_is_published
    within ".attributes" do
      expect(page).to have_content("published")
    end
  end

  def and_the_page_has_been_published_in_the_pipeline
    assert_publishing_api_publish(@content_id)
    assert_tag_published_in_panopticon(tag_type: "specialist_sector", tag_id: "citizenship")
  end

  def and_the_draft_is_sent_to_the_publishing_pipeline
    assert_publishing_api_put_item(
      @content_id,
      title: "Citizenship",
      description: "Living in the UK",
      format: "topic",
    )

    assert_publishing_api_put_links(@content_id)

    assert_publishing_api_not_published(@content_id)

    assert_tag_created_in_panopticon(
      tag_type: "specialist_sector",
      tag_id: "citizenship",
      title: "Citizenship",
      description: "Living in the UK",
    )
  end

  def and_the_published_data_is_sent_to_the_publishing_pipeline
    assert_publishing_api_put_item(
      @page.content_id,
      title: "Citizenship in the UK",
      format: "topic",
    )

    assert_publishing_api_put_links(@page.content_id)

    assert_publishing_api_publish(@page.content_id)

    assert_tag_updated_in_panopticon(
      tag_type: "specialist_sector",
      tag_id: "citizenship",
      title: "Citizenship in the UK",
      description: "Voting",
    )
  end

  def and_the_updated_item_is_sent_to_the_publishing_pipeline
    assert_publishing_api_put_item(
      @content_id,
      description: "A new description"
    )

    assert_tag_updated_in_panopticon(
      tag_type: "specialist_sector",
      tag_id: "citizenship",
      title: "Citizenship",
      description: "A new description",
    )
  end

  def then_I_see_a_validation_error
    expect(page).to have_content("Title can't be blank")
    expect(find("#topic_description").value).to eql "A changed description"
  end
end
