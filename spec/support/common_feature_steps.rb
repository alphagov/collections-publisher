module CommonFeatureSteps
  def and_external_services_are_stubbed
    stub_any_publishing_api_call
    publishing_api_has_no_linked_items
  end

  def given_i_am_a_gds_editor
    stub_user.permissions << "GDS Editor"
    stub_user.name = "Test author"
  end

  def given_i_am_not_a_gds_editor
    stub_user.permissions = %w[signin]
  end

  def and_i_submit_the_form
    find("input[type=submit]").click
  end

  def given_i_am_a_2i_reviewer
    stub_user.permissions << "2i reviewer"
  end

  def given_i_can_skip_review
    stub_user.permissions << "Skip review"
  end

  def required_permissions_for_2i
    ["signin", "GDS Editor", "2i reviewer"]
  end

  def required_permissions_to_skip_2i
    ["signin", "GDS Editor", "2i reviewer", "Skip review"]
  end

  def then_i_can_see_a_success_message(message)
    within(".gem-c-success-alert") do
      expect(page).to have_content message
    end
  end

  alias_method :and_i_can_see_a_success_message, :then_i_can_see_a_success_message
end
