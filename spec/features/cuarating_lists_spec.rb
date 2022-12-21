require "rails_helper"

RSpec.feature "Curating lists" do
  include CommonFeatureSteps
  include PublishingApiHelpers

  before do
    stub_any_publishing_api_call
    given_i_am_a_gds_editor
    and_i_have_the_redesigned_lists_permission
    and_there_are_is_a_child_object_with_curated_lists
    and_i_visit_the_child_show_page
  end

  scenario "adding a list" do
    when_i_click_the_add_list_link
    and_i_save_the_list
    then_i_am_told_to_provide_a_list_name

    when_i_enter_a_valid_name
    and_i_save_the_list
    then_i_see_the_new_list
    and_the_correct_calls_are_made_to_the_publishing_api_for_creating_a_list
  end

  scenario "Renaming a list" do
    when_i_click_the_rename_list_link
    and_i_update_the_list_name
    then_i_see_the_list_name_has_been_updated
    and_the_correct_calls_are_made_to_the_publishing_api_for_renaming_a_list
  end

  scenario "Reordering a list" do
    when_i_click_the_reorder_list_link
    and_i_reorder_the_list
    then_i_see_the_list_order_has_been_updated
    and_the_correct_calls_are_made_to_the_publishing_api_for_reordering_a_list
  end

  scenario "Deleting a list" do
    when_i_click_the_delete_list_link
    and_i_confirm_the_deletion
    then_the_list_has_been_deleted
    and_the_correct_calls_are_made_to_the_publishing_api_for_deleting_a_list
  end

  def and_there_are_is_a_child_object_with_curated_lists
    @parent = create(:topic, :published)
    @child = create(:topic, :published, parent: @parent)
    @list1 = create(:list, tag: @child)
    @list2 = create(:list, tag: @child)
    publishing_api_has_linked_items(
      @child.content_id,
      items: [
        { base_path: "/naturalisation", title: "Naturalisation", content_id: "29941ec1-4a41-4bfd-86a9-5c866bbd4c7a" },
        { base_path: "/marriage", title: "Marriage", content_id: "29941ec1-4a41-4bfd-86a9-5c866bbd4c7b" },
      ],
    )
  end

  def and_i_visit_the_child_show_page
    visit topic_path(@child)
  end

  def when_i_click_the_add_list_link
    click_link "Add list"
  end

  def and_i_save_the_list
    click_button "Add list"
  end

  def then_i_am_told_to_provide_a_list_name
    expect(page).to have_content "Enter a name"
  end

  def when_i_enter_a_valid_name
    fill_in "Add new list", with: "David Lister"
  end

  def then_i_see_the_new_list
    expect(all(".gem-c-document-list__item")[2]).to have_content "David Lister"
  end

  def and_the_correct_calls_are_made_to_the_publishing_api_for_creating_a_list
    assert_publishing_api_put_content(
      @child.content_id,
      request_json_includes(
        "details" => {
          "groups" => [
            {
              "name" => @list1.name,
              "content_ids" => [],
            },
            {
              "name" => @list2.name,
              "content_ids" => [],
            },
            {
              "name" => "David Lister",
              "content_ids" => [],
            },
          ],
          "internal_name" => @child.title_including_parent,
        },
      ),
    )
    assert_publishing_api_publish(@child.content_id)
    assert_publishing_api_patch_links(@child.content_id)
  end

  def when_i_click_the_rename_list_link
    click_link "Rename list", match: :first
  end

  def and_i_update_the_list_name
    fill_in "Update a list", with: "Updated list name"
    click_button "Update name"
  end

  def then_i_see_the_list_name_has_been_updated
    expect(all(".gem-c-document-list__item")[0]).to have_content "Updated list name"
  end

  def and_the_correct_calls_are_made_to_the_publishing_api_for_renaming_a_list
    assert_publishing_api_put_content(
      @child.content_id,
      request_json_includes(
        "details" => {
          "groups" => [
            {
              "name" => "Updated list name",
              "content_ids" => [],
            },
            {
              "name" => @list2.name,
              "content_ids" => [],
            },
          ],
          "internal_name" => @child.title_including_parent,
        },
      ),
    )
    assert_publishing_api_publish(@child.content_id)
    assert_publishing_api_patch_links(@child.content_id)
  end

  def when_i_click_the_reorder_list_link
    click_link "Reorder list"
  end

  def and_i_reorder_the_list
    fill_in @list1.name, with: "2"
    fill_in @list2.name, with: "1"
    click_button "Update order"
  end

  def then_i_see_the_list_order_has_been_updated
    within "#curated-lists" do
      expect(all(".gem-c-document-list__item-title")[0].text).to eq @list2.name
    end
  end

  def and_the_correct_calls_are_made_to_the_publishing_api_for_reordering_a_list
    assert_publishing_api_put_content(
      @child.content_id,
      request_json_includes(
        "details" => {
          "groups" => [
            {
              "name" => @list2.name,
              "content_ids" => [],
            },
            {
              "name" => @list1.name,
              "content_ids" => [],
            },
          ],
          "internal_name" => @child.title_including_parent,
        },
      ),
    )
    assert_publishing_api_publish(@child.content_id)
    assert_publishing_api_patch_links(@child.content_id)
  end

  def when_i_click_the_delete_list_link
    click_link "Delete list", match: :first
  end

  def and_i_confirm_the_deletion
    click_button "Delete list"
  end

  def then_the_list_has_been_deleted
    expect(all(".gem-c-document-list__item-title").count).to eq 1
    expect(all(".gem-c-document-list__item-title")[0].text).to eq @list2.name
  end

  def and_the_correct_calls_are_made_to_the_publishing_api_for_deleting_a_list
    assert_publishing_api_put_content(
      @child.content_id,
      request_json_includes(
        "details" => {
          "groups" => [
            {
              "name" => @list2.name,
              "content_ids" => [],
            },
          ],
          "internal_name" => @child.title_including_parent,
        },
      ),
    )
    assert_publishing_api_publish(@child.content_id)
    assert_publishing_api_patch_links(@child.content_id)
  end
end
