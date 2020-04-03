require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.feature "Publish updates to Coronavirus landing page" do
  include CommonFeatureSteps
  include GdsApi::TestHelpers::PublishingApi

  before do
    given_i_am_a_coronavirus_editor
    stub_coronavirus_publishing_api
    stub_github_request
    stub_any_publishing_api_put_intent
  end

  scenario "User views the page" do
    when_i_visit_the_publish_coronavirus_page
    i_see_an_update_draft_button
    and_a_preview_button
    and_a_publish_button
  end

  scenario "Updating draft" do
    when_i_visit_the_publish_coronavirus_page
    and_i_push_a_new_draft_version
    then_the_content_is_sent_to_publishing_api
    and_i_see_a_draft_updated_message
  end

  scenario "Updating draft with invalid content" do
    when_i_visit_the_publish_coronavirus_page
    and_i_push_a_new_draft_version_with_invalid_content
    and_i_see_an_alert
  end

  scenario "Publishing page" do
    when_i_visit_the_publish_coronavirus_page
    and_i_choose_a_major_update
    and_i_publish_the_page
    then_the_page_publishes
    and_i_see_a_page_published_message
  end

  def given_i_am_a_coronavirus_editor
    stub_user.permissions << "Coronavirus editor"
    stub_user.name = "Test author"
  end

  def stub_coronavirus_publishing_api
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  def stub_github_request
    stub_request(:get, "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml")
      .to_return(status: 200, body: github_response)
  end

  def github_response
    File.read(Rails.root.join + "spec/fixtures/coronavirus_landing_page.yml")
  end

  def then_the_content_is_sent_to_publishing_api
    assert_publishing_api_put_content(
      "774cee22-d896-44c1-a611-e3109cce8eae",
      request_json_includes(
        "title" => "Coronavirus (COVID-19): what you need to do",
      ),
    )
  end

  def when_i_visit_the_publish_coronavirus_page
    visit "/coronavirus"
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

  def and_i_push_a_new_draft_version
    click_on("Update draft")
  end

  def and_i_push_a_new_draft_version_with_invalid_content
    stub_request(:get, "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_landing_page.yml")
    .to_return(status: 200, body: invalid_github_response)

    and_i_push_a_new_draft_version
  end

  def invalid_github_response
    File.read(Rails.root.join + "spec/fixtures/invalid_corona_page.yml")
  end

  def and_i_see_an_alert
    expect(page).to have_text("Invalid content - please recheck GitHub and add title, stay_at_home, guidance, announcements_label, announcements, nhs_banner, sections, topic_section, notifications.")
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

  def and_i_see_a_page_published_message
    expect(page).to have_text("Page published!")
  end
end
