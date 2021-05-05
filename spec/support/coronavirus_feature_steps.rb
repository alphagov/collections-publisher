require_relative "coronavirus_helpers"

module CoronavirusFeatureSteps
  include CoronavirusHelpers

  def given_i_am_a_coronavirus_editor
    stub_user.permissions << "Coronavirus editor"
    stub_user.name = "Test author"
  end

  def given_i_can_access_unreleased_features
    stub_user.permissions << "Unreleased feature"
  end

  def given_there_is_a_coronavirus_page
    @coronavirus_page = FactoryBot.create(:coronavirus_page, slug: "landing")
  end

  def given_there_is_coronavirus_page_with_announcements
    @coronavirus_page = FactoryBot.create(:coronavirus_page, slug: "landing")
    @announcement_one = FactoryBot.create(:coronavirus_announcement, position: 0, page: @coronavirus_page)
    @announcement_two = FactoryBot.create(:coronavirus_announcement, position: 1, page: @coronavirus_page)
  end

  def given_there_is_a_coronavirus_page_with_timeline_entries
    @coronavirus_page = FactoryBot.create(:coronavirus_page, slug: "landing")
    @timeline_entry_two = FactoryBot.create(:coronavirus_timeline_entry, page: @coronavirus_page, heading: "Two")
    @timeline_entry_one = FactoryBot.create(:coronavirus_timeline_entry, page: @coronavirus_page, heading: "One")
  end

  def given_there_is_a_published_coronavirus_page
    @coronavirus_page = FactoryBot.create(:coronavirus_page, :landing, state: "published")
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

  def raw_content_urls
    @raw_content_urls ||=
      Coronavirus::Pages::Configuration.all_pages.map do |config|
        config.second[:raw_content_url]
      end
  end

  def stub_all_github_requests
    raw_content_urls.each do |url|
      stub_request(:get, Regexp.new(url))
        .to_return(status: 200, body: github_response)
    end
  end

  def stub_github_business_request
    stub_request(:get, Regexp.new("https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml"))
      .to_return(status: 200, body: github_business_response)
  end

  def github_response
    File.read(Rails.root.join + "spec/fixtures/coronavirus_landing_page.yml")
  end

  def github_business_response
    File.read(Rails.root.join + "spec/fixtures/coronavirus_business_page.yml")
  end

  def then_the_content_is_sent_to_publishing_api
    assert_publishing_api_put_content(
      "774cee22-d896-44c1-a611-e3109cce8eae",
      request_json_includes(
        "title" => "Coronavirus (COVID-19): what you need to do",
      ),
    )
  end

  def then_the_business_content_is_sent_to_publishing_api
    assert_publishing_api_put_content(
      "09944b84-02ba-4742-a696-9e562fc9b29d",
      request_json_includes(
        "title" => "Business support",
      ),
    )
  end

  def i_see_a_publish_landing_page_link
    expect(page).to have_link(I18n.t("coronavirus.pages.index.landing_page_edit.something_else"))
  end

  def i_see_a_publish_business_page_link
    expect(page).to have_link(I18n.t("coronavirus.pages.index.subtopic_edit.something_else", page_name: "business hub"))
  end

  def and_i_select_landing_page
    click_link(I18n.t("coronavirus.pages.index.landing_page_edit.something_else"))
  end

  def and_i_select_business_page
    click_link(I18n.t("coronavirus.pages.index.subtopic_edit.something_else", page_name: "business hub"))
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

  def when_i_visit_the_reorder_announcements_page
    visit "/coronavirus/landing/announcements/reorder"
  end

  def then_i_can_see_an_announcements_section
    expect(page).to have_content(I18n.t("coronavirus.pages.show.announcements.title"))
    expect(page).to have_link(I18n.t("coronavirus.pages.show.announcements.reorder"), href: reorder_coronavirus_page_announcements_path(@coronavirus_page.slug))
    expect(page).to have_link(I18n.t("coronavirus.pages.show.announcements.add"))
  end

  def then_i_can_see_a_timeline_entries_section
    expect(page).to have_content(I18n.t("coronavirus.pages.show.timeline_entries.title"))
    expect(page).to have_link(I18n.t("coronavirus.pages.show.timeline_entries.reorder"), href: reorder_coronavirus_page_timeline_entries_path(@coronavirus_page.slug))
    expect(page).to have_link(I18n.t("coronavirus.pages.show.timeline_entries.add"))
  end

  def then_i_cannot_see_an_announcements_section
    expect(page).to_not have_content(I18n.t("coronavirus.pages.show.announcements.title"))
  end

  def then_i_cannot_see_a_timeline_entries_section
    expect(page).to_not have_content(I18n.t("coronavirus.pages.show.announcements.title"))
  end

  def and_i_can_see_existing_announcements
    expect(page).to have_content(@announcement_one.title)
    expect(page).to have_content(@announcement_two.title)
  end

  def and_i_can_see_existing_timeline_entries
    expect(page).to have_content(@timeline_entry_one.heading)
    expect(page).to have_content(@timeline_entry_two.heading)
  end

  def then_i_see_the_announcements_in_order
    expect(page).to have_content(
      /#{@announcement_one.title}.*#{@announcement_two.title}/,
      normalize_ws: true,
    )
  end

  def when_i_move_announcement_one_down
    stub_coronavirus_landing_page_content(@coronavirus_page)

    within(".gem-c-reorderable-list__item:first-child") { click_button "Down" }
    click_button "Save"
  end

  def then_i_see_announcement_updated_message
    expect(page).to have_content I18n.t("coronavirus.reorder_announcements.update.success")
  end

  def and_i_see_the_announcements_have_changed_order
    expect(page).to have_content(
      /#{@announcement_two.title}.*#{@announcement_one.title}/,
      normalize_ws: true,
    )
  end

  # Adding an announcement

  def and_i_add_a_new_announcement
    click_on(I18n.t("coronavirus.pages.show.announcements.add"))
  end

  def then_i_see_the_create_announcement_form
    expect(page).to have_text(I18n.t("coronavirus.announcements.form.title.label"))
    expect(page).to have_text(I18n.t("coronavirus.announcements.form.url.label"))
    expect(page).to have_text(I18n.t("coronavirus.announcements.form.date.legend"))
  end

  def when_i_fill_in_the_announcement_form_with_valid_data
    stub_coronavirus_landing_page_content(@coronavirus_page)
    fill_in("title", with: "fancy title")
    fill_in("url", with: "/government")
    fill_in("announcement[published_on][day]", with: "12")
    fill_in("announcement[published_on][month]", with: "1")
    fill_in("announcement[published_on][year]", with: "2020")
    click_on("Save")
  end

  def then_i_can_see_a_new_announcement_has_been_created
    expect(current_path).to eq("/coronavirus/landing")
    expect(expect(page).to(have_text("fancy title")))
  end

  def when_i_delete_an_announcement
    stub_coronavirus_landing_page_content(@coronavirus_page)

    page.accept_alert I18n.t("coronavirus.pages.show.announcements.confirm") do
      page.find("a[href=\"/coronavirus/landing/announcements/#{@announcement_one.id}\"]", text: "Delete").click
    end
  end

  def then_i_can_see_an_announcement_has_been_deleted
    expect(page).to have_text(I18n.t("coronavirus.announcements.destroy.success"))
    expect(page).not_to(have_text(@announcement_one.title))
  end

  def when_i_can_click_change_for_an_announcement
    page.find("a[href=\"/coronavirus/landing/announcements/#{@announcement_one.id}/edit\"]", text: "Change").click
  end

  def then_i_see_the_edit_announcement_form
    expect(page).to have_text(I18n.t("coronavirus.announcements.edit.title"))
  end

  def when_i_can_edit_the_announcement_form_with_valid_data
    stub_coronavirus_landing_page_content(@coronavirus_page)
    fill_in("title", with: "Updated title")
    click_on("Save")
  end

  def then_i_can_see_that_the_announcement_has_been_updated
    expect(page).to have_content(I18n.t("coronavirus.announcements.update.success"))
    expect(page).to have_content("Updated title")
  end

  # Adding a timeline entry

  def and_i_add_a_new_timeline_entry
    click_on(I18n.t("coronavirus.pages.show.timeline_entries.add"))
  end

  def then_i_see_the_timeline_entry_form
    expect(page).to have_text(I18n.t("coronavirus.timeline_entries.form.heading.label"))
    expect(page).to have_text(I18n.t("coronavirus.timeline_entries.form.content.label"))
  end

  def when_i_fill_in_the_timeline_entry_form_with_valid_data
    stub_coronavirus_landing_page_content(@coronavirus_page)
    fill_in("heading", with: "Fancy title")
    fill_in("content", with: "##Form content")
    click_on("Save")
  end

  def then_i_see_a_new_timeline_entry_has_been_created
    expect(current_path).to eq("/coronavirus/landing")
    expect(page).to have_text("Fancy title")
  end

  # Editing timeline entries

  def and_i_change_a_timeline_entry
    page.find("a[href=\"/coronavirus/landing/timeline_entries/#{@timeline_entry_one.id}/edit\"]", text: "Change").click
  end

  def when_i_visit_the_edit_timeline_entry_page
    visit "/coronavirus/landing/timeline_entries/#{@timeline_entry_one.id}/edit"
  end

  def and_i_see_the_existing_timeline_entry_data
    expect(page).to have_selector("input[value='#{@timeline_entry_one.heading}']")
    expect(page).to have_content(@timeline_entry_one.content)
  end

  def then_i_see_the_timeline_entry_has_been_updated
    expect(current_path).to eq("/coronavirus/landing")
    expect(page).to have_text("Fancy title")
  end

  # Reordering timeline entries

  def when_i_visit_the_reorder_timeline_entries_page
    visit "/coronavirus/landing/timeline_entries/reorder"
  end

  def then_i_see_the_timeline_entries_in_order
    expect(page).to have_content(
      /#{@timeline_entry_one.heading}.*#{@timeline_entry_two.heading}/,
      normalize_ws: true,
    )
  end

  def when_i_move_timeline_entry_one_down
    stub_coronavirus_landing_page_content(@coronavirus_page)

    within(".gem-c-reorderable-list__item:first-child") { click_button "Down" }
    click_button "Save"
  end

  def then_i_see_timeline_entries_updated_message
    expect(page).to have_content I18n.t("coronavirus.reorder_timeline_entries.update.success")
  end

  def and_i_see_the_timeline_entries_have_changed_order
    expect(page).to have_content(
      /#{@timeline_entry_two.heading}.*#{@timeline_entry_one.heading}/,
      normalize_ws: true,
    )
  end

  # Deleting timeline entries

  def when_i_delete_a_timeline_entry
    stub_coronavirus_landing_page_content(@coronavirus_page)

    page.accept_alert "Are you sure?" do
      page.find("a[href=\"/coronavirus/landing/timeline_entries/#{@timeline_entry_one.id}\"]", text: "Delete").click
    end
  end

  def then_i_can_see_the_timeline_entry_has_been_deleted
    expect(page).to have_text(I18n.t("coronavirus.timeline_entries.destroy.success"))
    expect(page).not_to have_text(@timeline_entry_one.heading)
  end

  def set_up_basic_sub_sections
    @coronavirus_page = FactoryBot.create(:coronavirus_page, :landing, state: "published")
    FactoryBot.create(:coronavirus_sub_section,
                      page: @coronavirus_page,
                      position: 0,
                      title: "I am first",
                      content: "###title\n[label](/url?priority-taxon=#{@coronavirus_page.content_id})")
    FactoryBot.create(:coronavirus_sub_section,
                      page: @coronavirus_page,
                      position: 1,
                      title: "I am second",
                      content: "###title\n[label](/url?priority-taxon=#{@coronavirus_page.content_id})")
    path = Rails.root.join "spec/fixtures/simple_coronavirus_page.yml"
    github_yaml_content = File.read(path)
    stub_request(:get, /#{@coronavirus_page.raw_content_url}\?cache-bust=\d+/)
      .to_return(status: 200, body: github_yaml_content)
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
        "sub_sections" => [section],
      },
      {
        "title" => "I am first",
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

  def i_see_an_update_draft_button
    expect(page).to have_button(I18n.t("coronavirus.github_changes.index.instructions.three.button_text"))
  end

  def and_a_preview_button
    expect(page).to have_link(I18n.t("coronavirus.github_changes.index.instructions.four.button_text"))
    expect(find_link(I18n.t("coronavirus.github_changes.index.instructions.four.button_text"))[:target]).to eq("_blank")
  end

  def and_a_publish_button
    expect(page).to have_button(I18n.t("coronavirus.github_changes.index.instructions.five.button_text"))
  end

  def and_a_view_live_business_content_button
    expect(page).to have_link(I18n.t("coronavirus.github_changes.index.instructions.six.button_text"), href: "https://www.test.gov.uk/coronavirus/business-support")
  end

  def and_i_push_a_new_draft_version
    click_on(I18n.t("coronavirus.github_changes.index.instructions.three.button_text"))
  end

  def and_i_push_a_new_draft_version_with_invalid_content
    stub_request(:get, Regexp.new("https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml"))
    .to_return(status: 200, body: invalid_github_response)

    and_i_push_a_new_draft_version
  end

  def and_i_push_a_new_draft_business_version_with_invalid_content
    stub_request(:get, Regexp.new("https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml"))
    .to_return(status: 200, body: invalid_github_response)

    and_i_push_a_new_draft_version
  end

  def invalid_github_response
    File.read(Rails.root.join + "spec/fixtures/invalid_corona_page.yml")
  end

  def and_i_see_an_alert
    expect(page).to have_text("Invalid content in GitHub YAML")
  end

  def and_i_see_a_draft_updated_message
    expect(page).to have_text(I18n.t("coronavirus.github_changes.update.success"))
  end

  def and_i_choose_a_major_update
    choose(I18n.t("coronavirus.github_changes.index.instructions.five.radio_options.major"))
  end

  def and_i_publish_the_page
    click_on(I18n.t("coronavirus.github_changes.index.instructions.five.button_text"))
  end

  def then_the_page_publishes
    assert_publishing_api_publish("774cee22-d896-44c1-a611-e3109cce8eae", update_type: "major")
  end

  def then_the_page_publishes_a_minor_update
    assert_publishing_api_publish(@coronavirus_page.content_id, update_type: "minor")
  end

  def then_the_business_page_publishes
    assert_publishing_api_publish("09944b84-02ba-4742-a696-9e562fc9b29d", update_type: "major")
  end

  def and_i_remain_on_the_coronavirus_page
    expect(current_path).to eq("/coronavirus/landing")
  end

  def and_i_remain_on_the_coronavirus_github_changes_page
    expect(current_path).to eq("/coronavirus/landing/github_changes")
  end

  def and_i_see_a_page_published_message
    expect(page).to have_text(I18n.t("coronavirus.pages.publish.success"))
  end

  def and_i_see_github_changes_published_message
    expect(page).to have_text(I18n.t("coronavirus.github_changes.publish.success"))
  end
end
