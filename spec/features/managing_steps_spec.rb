require "rails_helper"

RSpec.feature "Managing step by step pages" do
  include CommonFeatureSteps
  include NavigationSteps
  include StepNavSteps

  context "Given I'm a GDS Editor" do
    before do
      given_I_am_a_GDS_editor
      setup_publishing_api
    end

    context 'and I would like to create and manage steps on a step by step page' do
      scenario "User creates a step" do
        given_there_is_a_step_by_step_page
        when_I_visit_the_step_by_step_page
        and_I_create_a_new_step
        and_I_fill_in_the_form
        then_the_content_is_sent_to_publishing_api
        and_I_see_the_step_on_the_step_by_step_details_page
      end

      scenario "User edits step" do
        given_there_is_a_step_by_step_page_with_steps
        when_I_visit_the_step_by_step_page
        and_I_edit_the_first_step
        then_I_can_see_the_edit_page
        and_I_fill_in_the_form
        then_the_content_is_sent_to_publishing_api
        and_I_see_the_step_on_the_step_by_step_details_page
      end

      scenario "User deletes step", js: true do
        given_there_is_a_step_by_step_page_with_steps
        when_I_visit_the_step_by_step_page
        and_I_can_see_the_first_step
        and_I_delete_the_first_step
        then_the_content_is_sent_to_publishing_api
        and_the_step_is_deleted
      end
    end

    context 'and I would like to reorder the steps on a step by step page' do
      before do
        allow(Services.publishing_api).to(
          receive(:lookup_content_id).with(
            base_path: "/how-to-be-the-amazing-1",
            with_drafts: true
          )
        )
      end

      scenario "User cannot reorder steps if none exist" do
        given_there_is_a_step_by_step_page
        when_I_visit_the_step_by_step_page
        then_I_cannot_see_the_button_to_reorder_steps
        and_I_visit_the_reorder_steps_page
        then_I_cannot_reorder_steps
      end

      scenario "User reorders steps", js: true do
        given_there_is_a_step_by_step_page_with_steps
        and_I_visit_the_reorder_steps_page
        and_I_reorder_the_steps
        then_the_payload_contains_the_new_steps_order
        and_I_see_the_steps_updated_on_the_step_by_step_details_page
      end
    end
  end


  def given_there_is_a_step_by_step_page_with_steps
    @step_by_step_page = create(:step_by_step_page_with_steps)
  end

  def given_there_is_a_step_by_step_page
    @step_by_step_page = create(:step_by_step_page)
  end

  def when_I_visit_the_step_by_step_page
    visit step_by_step_page_path(@step_by_step_page)
  end

  def and_I_visit_the_reorder_steps_page
    visit step_by_step_page_reorder_path(@step_by_step_page)
  end

  def and_I_create_a_new_step
    click_on "Add a new step"
  end

  def and_I_edit_the_first_step
    within("table") do
      click_on "Edit", match: :first
    end
  end

  def and_I_reorder_the_steps
    click_on "Down", match: :first
    click_on "Save"
  end

  def then_I_cannot_reorder_steps
    expect(page).not_to have_css("button", text: "Down")
    expect(page).not_to have_css("button", text: "Up")
    expect(page).to have_content("There are currently no steps to display.")
  end

  def then_I_cannot_see_the_button_to_reorder_steps
    expect(page).not_to have_css("button", text: "Reorder steps")
  end

  def and_I_can_see_the_first_step
    expect(page).to have_css("th", text: "Check how awesome you are")
  end

  def and_I_delete_the_first_step
    accept_confirm do
      click_on "Delete", match: :first
    end
  end

  def and_the_step_is_deleted
    expect(page).not_to have_css("th", text: "Check how awesome you are")
  end

  def then_I_can_see_the_edit_page
    expect(page).to have_css("label", text: "Step title")
  end

  def and_I_fill_in_the_form
    fill_in "Step title", with: "Buy Mary Berry's 'Simple Cakes' book"
    choose "number"
    choose "essential"
    fill_in "Content in this step", with: "* [Booky booky book book.com](http://bbbb.com)\n* [Words inside cardboard.com](http://wic.com)"
    click_on "Save step"
  end

  def and_I_see_the_step_on_the_step_by_step_details_page
    expect(page).to have_content("Add a new step")
    expect(page).to have_content("Buy Mary Berry's 'Simple Cakes' book")
  end

  def then_the_payload_contains_the_new_steps_order
    presenter = StepNavPresenter.new(@step_by_step_page.reload)
    payload = presenter.render_for_publishing_api

    payload_steps = payload[:details][:step_by_step_nav][:steps]

    expect(payload_steps[0][:title]).to eql("Dress like the Fonz")
    expect(payload_steps[1][:title]).to eql("Check how awesome you are")
  end

  def and_I_see_the_steps_updated_on_the_step_by_step_details_page
    expect(page).to have_css("table > tbody > tr:nth-child(1) > th:nth-child(2)", text: "Dress like the Fonz")
    expect(page).to have_css("table > tbody > tr:nth-child(2) > th:nth-child(2)", text: "Check how awesome you are")
  end
end
