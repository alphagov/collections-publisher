require "rails_helper"

RSpec.feature "Managing secondary content for step by step pages" do
  include CommonFeatureSteps
  include StepNavSteps

  before do
    given_I_am_a_GDS_editor
    setup_publishing_api
  end

  scenario "User views secondary content links" do
    given_there_is_a_step_by_step_page_with_secondary_content
    when_I_visit_the_step_by_step_page
    and_I_click_the_secondary_links_edit_link
    then_I_can_see_the_existing_secondary_content_listed
  end

  scenario "User adds new secondary content link" do
    given_there_is_a_step_by_step_page_with_secondary_content
    when_I_visit_the_secondary_content_page
    and_I_add_secondary_content
    then_I_can_see_a_success_message "Secondary content was successfully linked."
    and_I_can_see_the_new_secondary_content_listed
    and_I_should_still_be_on_the_secondary_links_page
  end

  scenario "User tries to add broken secondary link" do
    given_there_is_a_step_by_step_page_with_secondary_content
    when_I_visit_the_secondary_content_page
    and_I_try_to_add_secondary_content_with_a_broken_link
    then_I_should_see_a_failure_notice
    and_I_should_still_be_on_the_secondary_links_page
  end

  scenario "User removes a secondary content link" do
    given_there_is_a_step_by_step_page_with_secondary_content
    when_I_visit_the_secondary_content_page
    and_I_delete_secondary_content
    then_I_should_see_a_successfully_deleted_notice
    and_I_should_still_be_on_the_secondary_links_page
    and_I_cannot_see_any_secondary_content_listed
  end

  def given_there_is_a_step_by_step_page_with_secondary_content
    @step_by_step_page = create(:step_by_step_page_with_secondary_content)
  end

  def when_I_visit_the_step_by_step_page
    visit step_by_step_page_path(@step_by_step_page)
  end

  def and_I_add_secondary_content
    setup_publishing_api_request_expectations
    expect_update_worker

    fill_in "base_path", with: base_path
    find("button[type=submit]").click
  end

  def and_I_try_to_add_secondary_content_with_a_broken_link
    fill_in "base_path", with: broken_base_path
    find("button[type=submit]").click
  end

  def and_I_delete_secondary_content
    expect_update_worker

    find(".govuk-button--warning").click
  end

  def and_I_click_the_secondary_links_edit_link
    click_on "Change Secondary links"
  end

  def when_I_visit_the_secondary_content_page
    when_I_visit_the_step_by_step_page
    and_I_click_the_secondary_links_edit_link
  end

  def and_I_should_still_be_on_the_secondary_links_page
    expect(current_url).to end_with step_by_step_page_secondary_content_links_path(@step_by_step_page)
  end

  def then_I_should_see_a_successfully_deleted_notice
    expect(page).to have_content("Secondary content link was successfully deleted.")
  end

  def then_I_should_see_a_failure_notice
    expect(page).to have_content("#{broken_base_path} doesn't exist on GOV.UK.")
  end

  def then_I_can_see_the_existing_secondary_content_listed
    expect(find("tbody")).to have_content(@step_by_step_page.secondary_content_links.first.title)
  end

  def and_I_can_see_the_new_secondary_content_listed
    expect(find("tbody")).to have_content(base_path)
  end

  def and_I_cannot_see_any_secondary_content_listed
    expect(find("tbody")).to have_content("No secondary links have been added yet.")
  end

  def setup_publishing_api_request_expectations
    allow(Services.publishing_api).to(
      receive(:lookup_content_id).and_return(content_id),
    )

    allow(Services.publishing_api).to(
      receive(:get_content).with(content_id).and_return(content_item),
    )
  end

  def base_path
    "/secondary-content"
  end

  def broken_base_path
    "/i-dont-exist"
  end

  def content_id
    "a-secondary-content-id"
  end

  def content_item
    {
      "content_id" => content_id,
      "base_path" => base_path,
      "title" => "A Secondary Content Link",
      "publishing_app" => "publisher",
      "schema_name" => "guide",
    }
  end
end
