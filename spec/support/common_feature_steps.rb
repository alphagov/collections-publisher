module CommonFeatureSteps
  def and_external_services_are_stubbed
    stub_all_panopticon_tag_calls
    allow_any_instance_of(RummagerNotifier).to receive(:notify)
    stub_any_publishing_api_call
    publishing_api_has_no_linked_items
  end

  def given_I_am_a_GDS_editor
    stub_user.permissions << "GDS Editor"
  end

  def given_I_am_not_a_GDS_editor
    stub_user.permissions = ['signin']
  end

  def and_I_submit_the_form
    find('input[type=submit]').click
  end
end
