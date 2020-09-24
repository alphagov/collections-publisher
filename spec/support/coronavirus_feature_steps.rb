def given_i_am_a_coronavirus_editor
  stub_user.permissions << "Coronavirus editor"
  stub_user.name = "Test author"
end

def given_i_can_access_unreleased_features
  stub_user.permissions << "Unreleased feature"
end

def given_a_livestream_exists
  FactoryBot.create(:live_stream, :without_validations)
end

def given_there_is_coronavirus_page_with_announcements
  @coronavirus_page = FactoryBot.create(:coronavirus_page, slug: "landing")
  @announcement = FactoryBot.create(:announcement, coronavirus_page: @coronavirus_page)
end

def the_payload_contains_the_valid_url
  live_stream_payload = coronavirus_live_stream_hash.merge(
    {
      "video_url" => valid_url,
      "date" => todays_date,
    },
  )
  assert_publishing_api_put_content(
    coronavirus_content_id,
    request_json_includes(
      "details" => {
        "announcements_label" => "Announcements",
        "live_stream" => live_stream_payload,
      },
    ),
  )
end

def live_coronavirus_content_item
  File.read(Rails.root.join("spec/fixtures/coronavirus_content_item.json"))
end

def coronavirus_content_json
  @coronavirus_content_json ||= JSON.parse(live_coronavirus_content_item)
end

def coronavirus_live_stream_hash
  coronavirus_content_json.dig("details", "live_stream")
end

def coronavirus_content_id
  coronavirus_content_json["content_id"]
end

def todays_date
  Time.zone.now.strftime("%-d %B %Y")
end

def invalid_url
  "https://www.yotbe.com/watch?v=UF8mC-T0u6k"
end

def valid_url
  "https://www.youtube.com/watch?v=UF8mC-T0u6k"
end

def stub_youtube
  stub_request(:get, valid_url)
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
    CoronavirusPages::Configuration.all_pages.map do |config|
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
  expect(page).to have_link("Edit something else on the landing page")
end

def i_see_a_publish_business_page_link
  expect(page).to have_link("Edit something else on the business hub")
end

def i_see_livestream_button
  expect(page).to have_link("Edit live stream URL")
end

def and_i_select_landing_page
  click_link("Edit something else on the landing page")
end

def and_i_select_business_page
  click_link("Edit something else on the business hub")
end

def and_i_select_live_stream
  click_link("Edit live stream URL")
  expect(page).to have_text("Update live stream URL")
end

def i_am_able_to_update_draft_content_with_valid_url
  fill_in("url", with: valid_url)
  click_on("Update draft")
  the_payload_contains_the_valid_url
end

def and_i_can_publish_the_url
  click_on("Publish")
  assert_publishing_api_publish("774cee22-d896-44c1-a611-e3109cce8eae", update_type: "minor")
end

def and_i_can_check_the_preview
  expect(page).to have_link("Preview", href: "https://draft-origin.test.gov.uk/coronavirus")
end

def i_am_able_to_submit_an_invalid_url
  fill_in("url", with: invalid_url)
  click_on("Update draft")
end

def when_i_visit_the_coronavirus_index_page
  visit "/coronavirus"
end

def when_i_visit_a_non_existent_page
  visit "/coronavirus/flimflam/prepare"
end

def when_i_visit_a_coronavirus_page
  visit "/coronavirus/landing"
end

### Reordering sections spec ##

def when_i_visit_the_reorder_page
  visit "/coronavirus/landing/sub_sections/reorder"
end

def then_i_can_see_an_announcements_section
  expect(page).to have_content("Announcements")
  expect(page).to have_link("Reorder", href: coronavirus_page_path(@coronavirus_page.slug))
  expect(page).to have_link("Add announcement")
end

def then_i_cannot_see_an_announcements_section
  expect(page).to_not have_content("Announcements")
end

def and_i_can_see_existing_announcements
  expect(page).to have_content(@announcement.text)
end

def set_up_basic_sub_sections
  coronavirus_page = FactoryBot.create(:coronavirus_page, :landing, state: "published")
  FactoryBot.create(:sub_section,
                    coronavirus_page_id: coronavirus_page.id,
                    position: 0,
                    title: "I am first",
                    content: "###title\n[label](/url)")
  FactoryBot.create(:sub_section,
                    coronavirus_page_id: coronavirus_page.id,
                    position: 1,
                    title: "I am second",
                    content: "###title\n[label](/url)")
  path = Rails.root.join "spec/fixtures/simple_coronavirus_page.yml"
  github_yaml_content = File.read(path)
  stub_request(:get, /#{coronavirus_page.raw_content_url}\?cache-bust=\d+/)
    .to_return(status: 200, body: github_yaml_content)
  stub_live_sub_sections_content_request(coronavirus_page.content_id)
end

def coronavirus_content_json_with_sections
  path = Rails.root.join("spec/fixtures/coronavirus_page_sections.json")
  JSON.parse(File.read(path))
end

def stub_live_sub_sections_content_request(content_id)
  content = coronavirus_content_json_with_sections
  content["content_id"] = content_id
  stub_publishing_api_has_item(content)
end

def stub_discard_subsection_changes
  stub_publishing_api_discard_draft(CoronavirusPage.topic_page.first.content_id)
end

def stub_discard_coronavirus_page_draft
  stub_publishing_api_discard_draft(coronavirus_content_id)
end

def stub_discard_coronavirus_page_no_draft
  stub_any_publishing_api_discard_draft
    .to_return(status: 422, body: "You do not have a draft to discard")
end

def i_see_subsection_one_in_position_one
  element = find("#step-0").find(".step-by-step-reorder__step-title")
  expect(element).to have_content "I am first"
end

def and_i_move_section_one_down
  find("#step-0").find(".js-order-controls").find(".js-down").click
  click_button "Save"
  expect(page).to have_content "Sections were successfully reordered."
end

def then_the_reordered_subsections_are_sent_to_publishing_api
  section = { "title" => "title", "list" => [{ "label" => "label", "url" => "/url" }] }
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
    CoronavirusPage.topic_page.first.content_id,
    request_json_includes(
      "details" => {
        "header_section" => "header_section",
        "announcements_label" => "announcements_label",
        "announcements" => "announcements",
        "nhs_banner" => "nhs_banner",
        "sections_heading" => "sections_heading",
        "topic_section" => "topic_section",
        "live_stream" => {
          "video_url" => LiveStream.first.url,
          "date" => LiveStream.first.formatted_stream_date,
        },
        "notifications" => "notifications",
        "sections" => reordered_sections,
        "hidden_search_terms" => hidden_search_terms.flatten.select(&:present?).uniq,
      },
    ),
  )
end

def then_i_see_section_updated_message
  expect(page).to have_text("Sections were successfully reordered.")
end

def and_i_see_state_is_published
  expect(CoronavirusPage.topic_page.first.state).to eq "published"
  expect(page).to have_text("Status: Published", normalize_ws: true)
end

def and_i_see_state_is_draft
  expect(CoronavirusPage.topic_page.first.state).to eq "draft"
  expect(page).to have_text("Status: Draft", normalize_ws: true)
end

def and_i_discard_my_changes
  click_link("Discard changes")
end

def i_see_error_message_no_changes_to_discard
  expect(page).to have_text("You do not have a draft to discard")
end

def then_i_am_redirected_to_the_index_page
  expect(current_path).to eq("/coronavirus")
end

def and_i_see_a_message_telling_me_that_the_page_does_not_exist
  expect(page).to have_text("'flimflam' is not a valid page")
end

def i_see_an_update_draft_button
  expect(page).to have_button("Update draft")
end

def and_a_preview_button
  expect(page).to have_link("Preview")
  expect(find_link("Preview")[:target]).to eq("_blank")
end

def and_a_publish_button
  expect(page).to have_button("Publish")
end

def and_a_view_live_business_content_button
  expect(page).to have_link("View live version", href: "https://www.test.gov.uk/coronavirus/business-support")
end

def and_i_push_a_new_draft_version
  click_on("Update draft")
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
  expect(page).to have_text("Invalid content - please recheck GitHub and add title, header_section, announcements_label, announcements, nhs_banner, sections, topic_section, notifications, live_stream.")
end

def and_i_see_an_alert_for_missing_hub_page_keys
  expect(page).to have_text("Invalid content - please recheck GitHub and add title, header_section, sections, topic_section, notifications.")
end

def and_i_see_a_draft_updated_message
  expect(page).to have_text("Draft content updated")
end

def and_i_choose_a_major_update
  choose("Major")
end

def and_i_publish_the_page
  click_on("Publish")
end

def then_the_page_publishes
  assert_publishing_api_publish("774cee22-d896-44c1-a611-e3109cce8eae", update_type: "major")
end

def then_the_page_publishes_a_minor_update
  assert_publishing_api_publish("774cee22-d896-44c1-a611-e3109cce8eae", update_type: "minor")
end

def then_the_business_page_publishes
  assert_publishing_api_publish("09944b84-02ba-4742-a696-9e562fc9b29d", update_type: "major")
end

def and_i_remain_on_the_coronavirus_page
  expect(current_path).to eq("/coronavirus/landing")
end

def and_i_remain_on_the_coronavirus_prepare_page
  expect(current_path).to eq("/coronavirus/landing/prepare")
end

def and_i_see_a_page_published_message
  expect(page).to have_text("Page published!")
end

def and_i_see_live_stream_is_updated_message
  expect(page).to have_text("Draft live stream url updated!")
end

def and_i_see_live_stream_is_published_message
  expect(page).to have_text("New live stream url published!")
end

def and_i_see_the_error_message
  expect(page).to have_text("Url is not valid. Please check it and try again.")
end

def and_nothing_is_sent_publishing_api
  assert_publishing_api_not_published("774cee22-d896-44c1-a611-e3109cce8eae")
end

def and_i_see_a_link_to_the_landing_page
  expect(page).to have_link("Check live", href: "https://www.test.gov.uk/coronavirus")
end
