def given_i_am_a_coronavirus_editor
  stub_user.permissions << "Coronavirus editor"
  stub_user.name = "Test author"
end

def the_payload_contains_the_valid_url
  assert_publishing_api_put_content(
    "774cee22-d896-44c1-a611-e3109cce8eae",
    request_json_includes(
      "details" => {
        "announcements_label" => "Announcements",
        "live_stream" => {
          "video_url" => valid_url,
          "date" => "1 April 2020",
          "date_text" => "Live streamed",
          "previous_videos" => {
            "url" => "https://www.youtube.com/user/Number10gov/videos",
          },
        },
      },
    ),
  )
end

def stub_publishing_api_live_content_request
  stub_publishing_api_has_item(JSON.parse(live_content_item))
end

def invalid_url
  "https://www.yotbe.com/watch?v=UF8mC-T0u6k"
end

def valid_url
  "https://www.youtube.com/watch?v=UF8mC-T0u6k"
end

def stub_restclient
  stub_request(:get, valid_url)
end

def stub_coronavirus_publishing_api
  stub_any_publishing_api_put_content
  stub_any_publishing_api_publish
  stub_publishing_api_live_content_request
end

def stub_github_request
  stub_request(:get, "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml")
    .to_return(status: 200, body: github_response)
end

def stub_github_business_request
  stub_request(:get, "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml")
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

def i_see_a_landing_page_button
  expect(page).to have_link("Coronavirus landing page")
end

def i_see_a_business_page_button
  expect(page).to have_link("Business support page")
end

def i_see_livestream_button
  expect(page).to have_link("Update live stream")
end

def and_i_select_landing_page
  click_on("Coronavirus landing page")
end

def and_i_select_business_page
  click_on("Business support page")
end

def and_i_select_live_stream
  click_on("Update live stream")
  expect(page).to have_text("Add a new live stream URL")
end

def i_am_able_to_submit_a_valid_url
  fill_in("url", with: valid_url)
  click_on("Submit")
end

def i_am_able_to_submit_an_invalid_url
  fill_in("url", with: invalid_url)
  click_on("Submit")
end

def when_i_visit_the_publish_coronavirus_page
  visit "/coronavirus"
end

def when_i_visit_a_non_existent_page
  visit "/coronavirus/flimflam"
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

def i_am_able_to_enter_a_new_url
  expect(page).to have_text("Add a new live stream URL")
  e
end

def and_i_push_a_new_draft_version_with_invalid_content
  stub_request(:get, "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml")
  .to_return(status: 200, body: invalid_github_response)

  and_i_push_a_new_draft_version
end

def and_i_push_a_new_draft_business_version_with_invalid_content
  stub_request(:get, "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml")
  .to_return(status: 200, body: invalid_github_response)

  and_i_push_a_new_draft_version
end

def invalid_github_response
  File.read(Rails.root.join + "spec/fixtures/invalid_corona_page.yml")
end

def live_content_item
  File.read(Rails.root.join + "spec/fixtures/coronavirus_content_item.json")
end

def and_i_see_an_alert
  expect(page).to have_text("Invalid content - please recheck GitHub and add title, stay_at_home, guidance, announcements_label, announcements, nhs_banner, sections, topic_section, notifications.")
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

def then_the_business_page_publishes
  assert_publishing_api_publish("09944b84-02ba-4742-a696-9e562fc9b29d", update_type: "major")
end

def and_i_see_a_page_published_message
  expect(page).to have_text("Page published!")
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
