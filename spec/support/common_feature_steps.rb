module CommonFeatureSteps
  def and_external_services_are_stubbed
    stub_any_publishing_api_call
    publishing_api_has_no_linked_items
  end

  def given_I_am_a_GDS_editor
    stub_user.permissions << "GDS Editor"
    stub_user.name = "Test author"
  end

  def given_I_am_not_a_GDS_editor
    stub_user.permissions = %w(signin)
  end

  def and_I_submit_the_form
    find("input[type=submit]").click
  end

  def given_I_am_a_2i_reviewer
    stub_user.permissions << "2i reviewer"
  end

  def required_permissions_for_2i
    ["signin", "GDS Editor", "2i reviewer"]
  end

  def then_I_can_see_a_success_message(message)
    within(".gem-c-success-alert") do
      expect(page).to have_content message
    end
  end

  alias_method :and_I_can_see_a_success_message, :then_I_can_see_a_success_message
end
