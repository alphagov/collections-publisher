require "rails_helper"

RSpec.feature "Curating a list" do
  include CommonFeatureSteps
  include PublishingApiHelpers

  before do
    stub_any_publishing_api_call
    given_i_am_a_gds_editor
    and_i_have_the_redesigned_lists_permission
    and_there_are_is_a_child_object_with_list_items
  end

  scenario "Adding a link to a list" do
    when_i_visit_the_child_show_page
    and_i_click_the_edit_list_link
    then_i_see_the_list_show_page
    and_the_link_items_should_link_to_the_live_page

    when_i_click_add_links_to_list
    and_i_submit_the_form_without_choosing_a_link
    then_i_am_told_to_select_a_link

    when_i_choose_a_link_to_add
    then_i_see_the_link_has_been_added
    and_the_correct_calls_are_made_to_the_publishing_api_for_editing_list_items
  end

  scenario "Reordering list items" do
    when_i_visit_the_list_show_page
    and_i_click_reorder
    and_i_reorder_the_link_items
    then_i_see_the_list_has_been_reordered
    and_the_correct_calls_are_made_to_the_publishing_api_for_reordering_list_items
  end

  scenario "Deleting a list item" do
    when_i_visit_the_list_show_page
    and_i_click_remove
    and_i_confirm_the_removal
    then_i_see_the_link_has_been_removed
    and_the_correct_calls_are_made_to_the_publishing_api_for_deleting_list_items
  end

  def and_there_are_is_a_child_object_with_list_items
    @parent = create(:topic, :published)
    @child = create(:topic, :published, parent: @parent)
    @list = create(:list, tag: @child)
    @list_item1 = create(:list_item, list: @list, index: 1)
    @list_item2 = create(:list_item, list: @list, index: 2)
    publishing_api_has_linked_items(
      @child.content_id,
      items: [
        { base_path: @list_item1.base_path, title: @list_item1.title, content_id: "29941ec1-4a41-4bfd-86a9-5c866bbd4c7a" },
        { base_path: @list_item2.base_path, title: @list_item2.title, content_id: "29941ec1-4a41-4bfd-86a9-5c866bbd4c7b" },
        { base_path: "/naturalisation", title: "Naturalisation", content_id: "29941ec1-4a41-4bfd-86a9-5c866bbd4c7c" },
        { base_path: "/marriage", title: "Marriage", content_id: "29941ec1-4a41-4bfd-86a9-5c866bbd4c7d" },
      ],
    )
  end

  def when_i_visit_the_child_show_page
    visit topic_path(@child)
  end

  def and_i_click_the_edit_list_link
    click_link "Edit list"
  end

  def then_i_see_the_list_show_page
    expect(page).to have_current_path(tag_list_path(@child, @list))
  end

  def and_the_link_items_should_link_to_the_live_page
    expect(all(".gem-c-document-list__item-title")[0].text).to eq @list.list_items.first.title
    expect(all(".gem-c-document-list__item-title")[0][:href]).to eq Plek.new.website_root + @list.list_items.ordered.first.base_path
  end

  def when_i_click_add_links_to_list
    click_link "Add links to list"
  end

  def and_i_submit_the_form_without_choosing_a_link
    click_button "Add link to list"
  end

  def then_i_am_told_to_select_a_link
    within "#error-summary" do
      expect(page).to have_content "Select a link to add to the list"
    end
  end

  def when_i_choose_a_link_to_add
    check "Naturalisation"
    click_button "Add link to list"
  end

  def then_i_see_the_link_has_been_added
    expect(all(".gem-c-document-list__item-title")[2].text).to eq "Naturalisation"
  end

  def and_the_correct_calls_are_made_to_the_publishing_api_for_editing_list_items
    assert_publishing_api_put_content(
      @child.content_id,
      request_json_includes(
        "details" => {
          "groups" => [
            {
              "name" => @list.name,
              "contents" => [
                @list_item1.base_path,
                @list_item2.base_path,
                "/naturalisation",
              ],
            },
          ],
          "internal_name" => @child.title_including_parent,
        },
      ),
    )
    assert_publishing_api_publish(@child.content_id)
    assert_publishing_api_patch_links(@child.content_id)
  end

  def when_i_visit_the_list_show_page
    visit tag_list_path(@child, @list)
  end

  def and_i_click_reorder
    click_link "Reorder links"
  end

  def and_i_reorder_the_link_items
    fill_in @list_item1.title, with: "2"
    fill_in @list_item2.title, with: "1"
    click_button "Update order"
  end

  def then_i_see_the_list_has_been_reordered
    expect(all(".list-items .gem-c-document-list__item-title")[0].text).to eq @list_item2.title
    expect(all(".list-items .gem-c-document-list__item-title")[1].text).to eq @list_item1.title
  end

  def and_the_correct_calls_are_made_to_the_publishing_api_for_reordering_list_items
    assert_publishing_api_put_content(
      @child.content_id,
      request_json_includes(
        "details" => {
          "groups" => [
            {
              "name" => @list.name,
              "contents" => [
                @list_item2.base_path,
                @list_item1.base_path,
              ],
            },
          ],
          "internal_name" => @child.title_including_parent,
        },
      ),
    )
    assert_publishing_api_publish(@child.content_id)
    assert_publishing_api_patch_links(@child.content_id)
  end

  def and_i_click_remove
    click_link "Remove", match: :first
  end

  def and_i_confirm_the_removal
    click_button "Remove link"
  end

  def then_i_see_the_link_has_been_removed
    expect(all(".list-items")[0].text).not_to have_content @list_item1.title
  end

  def and_the_correct_calls_are_made_to_the_publishing_api_for_deleting_list_items
    assert_publishing_api_put_content(
      @child.content_id,
      request_json_includes(
        "details" => {
          "groups" => [
            {
              "name" => @list.name,
              "contents" => [
                @list_item2.base_path,
              ],
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
