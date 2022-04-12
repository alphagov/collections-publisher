module CoronavirusFeatureSteps
  def given_i_am_a_coronavirus_editor
    stub_user.permissions << "Coronavirus editor"
    stub_user.name = "Test author"
  end

  def given_i_can_access_unreleased_features
    stub_user.permissions << "Unreleased feature"
  end

  def given_there_is_a_coronavirus_page
    @coronavirus_page = FactoryBot.create(:coronavirus_page)
  end

  def given_there_is_a_published_coronavirus_page
    @coronavirus_page = FactoryBot.create(:coronavirus_page, state: "published")
  end

  def live_coronavirus_content_item
    File.read(Rails.root.join("spec/fixtures/coronavirus_content_item.json"))
  end

  def coronavirus_content_json
    @coronavirus_content_json ||= JSON.parse(live_coronavirus_content_item)
  end

  def coronavirus_content_id
    coronavirus_content_json["content_id"]
  end

  def todays_date
    Time.zone.now.strftime("%-d %B %Y")
  end

  def stub_coronavirus_publishing_api
    stub_live_coronavirus_content_request
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  def stub_live_coronavirus_content_request
    stub_publishing_api_has_item(coronavirus_content_json)
  end

  def then_the_content_is_sent_to_publishing_api
    assert_publishing_api_put_content(
      "774cee22-d896-44c1-a611-e3109cce8eae",
      request_json_includes(
        "title" => "Coronavirus (COVID-19): what you need to do",
      ),
    )
  end

  def then_i_see_an_edit_landing_page_link
    expect(page).to have_link(I18n.t("coronavirus.pages.index.landing_page_edit.sections"))
  end

  def and_i_select_landing_page
    click_link(I18n.t("coronavirus.pages.index.landing_page_edit.something_else"))
  end

  def when_i_visit_the_coronavirus_index_page
    visit "/coronavirus"
  end

  def when_i_visit_a_coronavirus_page
    visit "/coronavirus/landing"
  end

  ### Reordering sections spec ##

  def when_i_visit_the_reorder_page
    visit "/coronavirus/landing/sub_sections/reorder"
  end

  # Editing the header section

  def then_i_can_see_a_header_section
    expect(page).to have_content(I18n.t("coronavirus.pages.show.header_section.title"))
  end

  def when_i_edit_the_header_section
    page.find("a[href=\"/coronavirus/landing/edit-header\"]", text: "Change").click
  end

  def then_i_can_see_the_edit_header_form
    expect(page).to have_text(I18n.t("coronavirus.pages.edit_header.form.body.label"))
    expect(page).to have_text(I18n.t("coronavirus.pages.edit_header.form.header_link.title"))
  end

  def when_i_fill_in_the_edit_header_form_with_valid_data
    fill_in("header_title", with: "Fancy title")
    fill_in("header_body", with: "##Form content")
    fill_in("header_link_pre_wrap_text", with: "Pre wrap text")
    fill_in("header_link_post_wrap_text", with: "Post wrap text")
    fill_in("header_link_url", with: "/link")
    click_on("Save")
  end

  def then_i_see_header_updated_message
    expect(page).to have_text(I18n.t("coronavirus.pages.update_header.success"))
  end

  def set_up_basic_sub_sections
    @coronavirus_page = FactoryBot.create(:coronavirus_page, state: "published")
    FactoryBot.create(:coronavirus_sub_section,
                      page: @coronavirus_page,
                      position: 0,
                      title: "I am first",
                      sub_heading: "sub heading",
                      content: "###title\n[label](/url?priority-taxon=#{@coronavirus_page.content_id})")
    FactoryBot.create(:coronavirus_sub_section,
                      page: @coronavirus_page,
                      position: 1,
                      title: "I am second",
                      sub_heading: nil,
                      content: "###title\n[label](/url?priority-taxon=#{@coronavirus_page.content_id})")
    stub_live_sub_sections_content_request(@coronavirus_page.content_id)
  end

  def coronavirus_content_json_with_sections(content_id)
    path = Rails.root.join("spec/fixtures/coronavirus_page_sections.json")
    JSON.parse(File.read(path).gsub("774cee22-d896-44c1-a611-e3109cce8eae", content_id))
  end

  def stub_live_sub_sections_content_request(content_id)
    content = coronavirus_content_json_with_sections(content_id)
    stub_publishing_api_has_item(content)
  end

  def stub_discard_subsection_changes
    stub_publishing_api_discard_draft(@coronavirus_page.content_id)
  end

  def stub_discard_coronavirus_page_draft
    stub_publishing_api_discard_draft(coronavirus_content_id)
  end

  def stub_discard_coronavirus_page_no_draft
    stub_live_sub_sections_content_request(@coronavirus_page.content_id)
    stub_any_publishing_api_discard_draft
      .to_return(status: 422, body: "You do not have a draft to discard")
  end

  def i_see_subsection_one_in_position_one
    expect(find(".gem-c-reorderable-list:first-child")).to have_content "I am first"
  end

  def and_i_move_section_one_down
    all("button", text: "Down").first.click
    click_button "Save"
    expect(page).to have_content(I18n.t("coronavirus.reorder_sub_sections.update.success"))
  end

  def then_the_reordered_subsections_are_sent_to_publishing_api
    section = {
      "title" => "title",
      "list" => [
        {
          "label" => "label",
          "url" => "/url?priority-taxon=#{@coronavirus_page.content_id}",
        },
      ],
    }
    reordered_sections = [
      {
        "title" => "I am second",
        "sub_heading" => nil,
        "sub_sections" => [section],
      },
      {
        "title" => "I am first",
        "sub_heading" => "sub heading",
        "sub_sections" => [section],
      },
    ]

    hidden_search_terms = reordered_sections.map do |reordered_section|
      [
        reordered_section["title"],
        section["title"],
        section["list"].first["label"],
      ]
    end

    assert_publishing_api_put_content(
      @coronavirus_page.content_id,
      lambda do |request|
        details = JSON.parse(request.body)["details"]
        expect(details).to match hash_including({
          "sections" => reordered_sections,
          "hidden_search_terms" => hidden_search_terms.flatten.select(&:present?).uniq,
        })
      end,
    )
  end

  def then_i_see_section_updated_message
    expect(page).to have_text(I18n.t("coronavirus.reorder_sub_sections.update.success"))
  end

  def and_i_see_state_is_published
    expect(@coronavirus_page.reload.state).to eq "published"
    expect(page).to have_text("Status: Published", normalize_ws: true)
  end

  def and_i_see_state_is_draft
    expect(@coronavirus_page.reload.state).to eq "draft"
    expect(page).to have_text("Status: Draft", normalize_ws: true)
  end

  def and_i_discard_my_changes
    click_link(I18n.t("coronavirus.pages.show.actions.discard_changes"))
  end

  def i_see_error_message_no_changes_to_discard
    expect(page).to have_text("You do not have a draft to discard")
  end

  def and_i_publish_the_page
    click_on(I18n.t("coronavirus.pages.show.actions.publish"))
  end

  def then_the_page_publishes
    assert_publishing_api_publish("774cee22-d896-44c1-a611-e3109cce8eae", update_type: "major")
  end

  def then_the_page_publishes_a_minor_update
    assert_publishing_api_publish(@coronavirus_page.content_id, update_type: "minor")
  end

  def and_i_remain_on_the_coronavirus_page
    expect(current_path).to eq("/coronavirus/landing")
  end

  def and_i_see_a_page_published_message
    expect(page).to have_text(I18n.t("coronavirus.pages.publish.success"))
  end
end
