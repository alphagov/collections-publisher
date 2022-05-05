require "rails_helper"

RSpec.feature "Curating lists" do
  include CommonFeatureSteps
  include PublishingApiHelpers

  before do
    stub_any_publishing_api_call
    given_i_am_a_gds_editor
    and_i_have_the_redesigned_lists_permission
    and_there_are_is_a_child_object_with_curated_lists

    when_i_visit_the_child_show_page
    and_i_click_the_add_list_link
    and_i_save_the_list
    then_i_am_told_to_provide_a_list_name

    when_i_enter_a_valid_name
    and_i_save_the_list
    then_i_see_the_new_list
    and_the_correct_calls_are_made_to_the_publishing_api_for_creating_a_list
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

  def and_i_click_the_add_list_link
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
              "contents" => [],
            },
            {
              "name" => @list2.name,
              "contents" => [],
            },
            {
              "name" => "David Lister",
              "contents" => [],
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
