require "rails_helper"
require "gds_api/test_helpers/content_store"
require "gds_api/test_helpers/email_alert_api"

RSpec.feature "Archiving topic tags" do
  include CommonFeatureSteps
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::ContentItemHelpers
  include GdsApi::TestHelpers::EmailAlertApi

  before do
    stub_any_publishing_api_call
    stub_any_email_alert_api_call
    publishing_api_has_no_linked_items

    # Background
    given_i_am_a_gds_editor
  end

  scenario "User visits an archived tag" do
    given_there_is_an_archived_topic
    when_i_visit_the_topic_edit_page
    then_i_see_that_archived_topics_cannot_be_modified
  end

  scenario "User archives published level 2 tag" do
    given_there_is_a_published_level_2_topic
    and_there_is_a_subscriber_list_for_the_topic
    and_i_visit_the_topic
    and_i_go_to_the_archive_page

    when_i_redirect_the_topic_to_a_successor_page
    then_the_tag_is_archived

    when_i_visit_the_topic_edit_page
    then_i_see_that_i_cannot_edit_the_page
  end

  scenario "User archives published level 2 tag and redirects to a document collection with a topic taxonomy override" do
    skip("Work in progress")
    given_there_is_a_published_level_2_topic
    and_there_is_a_subscriber_list_for_the_topic
    and_i_visit_the_topic
    and_i_go_to_the_archive_page

    expect_email_alert_api_to_receive_a_bulk_migrate_call(successor_slug: "successor-hmrc-document-collection", source_slug: "Bar")
    when_i_redirect_the_topic_to_a_document_collection_with_a_mapped_specialist_topic_content_id_and_a_subscriber_list
    then_the_tag_is_archived

    when_i_visit_the_topic_edit_page
    then_i_see_that_i_cannot_edit_the_page
  end

  scenario "User archives draft level 2 tag" do
    given_there_is_a_draft_level_2_topic
    and_i_visit_the_topic
    when_i_click_the_delete_button
    then_the_tag_is_deleted
  end

  scenario "User archives published level 1 tag" do
    given_there_is_a_published_level_1_topic
    and_i_visit_the_topic
    and_i_go_to_the_archive_page

    when_i_redirect_the_topic_to_a_successor_page
    then_the_tag_is_archived

    when_i_visit_the_topic_edit_page
    then_i_see_that_i_cannot_edit_the_page
    and_i_see_archived_subtopics
    and_i_cannot_see_the_action_to_edit_subtopics
  end

  scenario "User archives draft level 1 tag" do
    given_there_is_a_draft_level_1_topic
    and_i_visit_the_topic
    when_i_click_the_delete_button
    then_the_tag_is_deleted
  end

  scenario "User redirects to invalid basepath" do
    given_there_is_a_published_level_2_topic
    and_i_visit_the_topic
    and_i_go_to_the_archive_page
    when_i_submit_an_invalid_base_path_as_redirect
    then_i_see_that_the_url_isnt_valid
  end

  def then_the_tag_is_deleted
    expect { @topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def when_i_redirect_the_topic_to_a_successor_page
    stub_content_store_has_item("/a-successor-page")
    fill_in "topic_archival_form[successor_path]", with: "/a-successor-page"
    click_button "Archive and redirect to a page"
  end

  def expect_email_alert_api_to_receive_a_bulk_migrate_call(successor_slug:, source_slug:)
    expect(Services.email_alert_api).to receive(:bulk_migrate).with(successor_slug:, source_slug: )
  end

  def when_i_redirect_the_topic_to_a_document_collection_with_a_mapped_specialist_topic_content_id_and_a_subscriber_list
    @successor_url = "successor-hmrc-document-collection"
    content_id = "3518c240-f8b3-11ed-be56-0242ac120002"
    document_collection_content = content_item_for_base_path(@successor_url)
                                    .merge({ mapped_specialist_topic_content_id: @topic.content_id,
                                             schema_name: "document_collection",
                                             document_type: "document_collection",
                                             content_id:
                                           })
    there_is_a_subscriber_list_with_slug_for_content_id(content_id:, slug: @successor_url)

    stub_content_store_has_item(@successor_url, document_collection_content)
    fill_in "topic_archival_form[successor_path]", with: @successor_url
    click_button "Archive and redirect to a page"
  end

  def when_i_visit_the_topic_edit_page
    visit edit_topic_path(@topic)
  end

  def and_i_visit_the_topic
    visit topic_path(@topic)
  end

  def then_i_see_that_archived_topics_cannot_be_modified
    expect(page).to have_content "You cannot modify an archived specialist topic."
  end

  def given_there_is_an_archived_topic
    @topic = create(:topic, :archived)
  end

  def given_there_is_a_published_level_2_topic
    @topic = create(:topic, :published, slug: "bar", parent: create(:topic, slug: "foo"))
  end

  def given_there_is_a_draft_level_2_topic
    @topic = create(:topic, :draft, slug: "bar", parent: create(:topic, slug: "foo"))
  end

  def given_there_is_a_published_level_1_topic
    @topic = create(:topic, :published, slug: "bar", children: [create(:topic, :archived)])
  end

  def given_there_is_a_draft_level_1_topic
    @topic = create(:topic, :draft, slug: "bar")
  end

  def when_i_click_the_delete_button
    click_on "Delete"
  end

  def and_i_go_to_the_archive_page
    click_link "Archive"
  end

  def then_the_tag_is_archived
    expect(@topic.reload.archived?).to eql(true)
  end

  def then_i_see_that_i_cannot_edit_the_page
    expect(page).to have_content "You cannot modify an archived specialist topic."
  end

  def and_i_see_archived_subtopics
    expect(page).to have_content "Subtopics"
  end

  def and_i_cannot_see_the_action_to_edit_subtopics
    expect(page).not_to have_css(".govuk-table__header", text: "Actions")
    expect(page).not_to have_link("Edit")
  end

  def when_i_submit_an_invalid_base_path_as_redirect
    stub_content_store_does_not_have_item("/not-here")
    fill_in "topic_archival_form[successor_path]", with: "/not-here"
    click_button "Archive and redirect to a page"
  end

  def then_i_see_that_the_url_isnt_valid
    expect(page).to have_content("This URL isn't a valid target for a redirect on GOV.UK.")
  end

  def and_there_is_a_subscriber_list_for_the_topic
    there_is_a_subscriber_list_with_slug_for_content_id(slug: "Bar", content_id: @topic.content_id)
  end

  def there_is_a_subscriber_list_with_slug_for_content_id(slug:, content_id:)
    email_alert_api_has_subscriber_list_for_topic(
      content_id: content_id,
      list: { "title" => "Topic", "slug" => slug },
      )
  end
end

