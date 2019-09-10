module StepNavSteps
  def setup_publishing_api
    stub_any_publishing_api_put_content
    stub_any_publishing_api_discard_draft
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(Services.publishing_api).to receive(:lookup_content_ids).and_return(
      '/good/stuff' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e1',
      '/also/good/stuff' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e2',
      '/not/as/great' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e3'
    )
    allow(Services.publishing_api).to receive(:get_content).with("fd6b1901d-b925-47c5-b1ca-1e52197097e1").and_return(
      "base_path" => "/first-item-in-list-of-step-one",
      "title" => "The first item in the list for step one",
      "content_id" => "fd6b1901d-b925-47c5-b1ca-1e52197097e1",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "schema_name" => "transaction"
    )
    allow(Services.publishing_api).to receive(:get_content).with("fd6b1901d-b925-47c5-b1ca-1e52197097e2").and_return(
      "base_path" => "/first-item-in-list-of-step-two",
      "title" => "The first item in the list for step two",
      "content_id" => "fd6b1901d-b925-47c5-b1ca-1e52197097e2",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "schema_name" => "transaction"
    )
    allow(Services.publishing_api).to receive(:get_content).with("fd6b1901d-b925-47c5-b1ca-1e52197097e3").and_return(
      "base_path" => "/first-item-in-list-of-step-three",
      "title" => "The first item in the list for step three",
      "content_id" => "fd6b1901d-b925-47c5-b1ca-1e52197097e3",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "schema_name" => "transaction"
    )

    stub_any_publishing_api_publish
    stub_any_publishing_api_unpublish
    allow(Services.publishing_api).to receive(:get_content).and_return(
      state_history: { "1" => "published" }
    )
  end

  def then_the_content_is_sent_to_publishing_api
    assert_publishing_api_put_content(@step_by_step_page.content_id)
  end

  def then_the_page_is_unpublished
    assert_publishing_api_unpublish(@step_by_step_page.content_id)
  end

  def expect_update_worker
    allow(StepByStepDraftUpdateWorker).to receive(:perform_async).with(@step_by_step_page.id, stub_user.name)
  end

  def given_there_is_a_step_by_step_page
    @step_by_step_page = create(:step_by_step_page)
  end

  alias_method :given_there_is_a_draft_step_by_step_page_with_no_steps, :given_there_is_a_step_by_step_page

  def given_there_is_a_step_by_step_page_with_steps
    @step_by_step_page = create(:step_by_step_page_with_steps)
  end

  def given_there_is_a_step_by_step_page_with_navigation_rules
    @step_by_step_page = create(:step_by_step_page_with_navigation_rules)
  end

  def given_there_is_a_draft_step_by_step_page
    @step_by_step_page = create(:draft_step_by_step_page)
    expect(@step_by_step_page.status).to be_draft
  end

  def given_there_is_a_published_step_by_step_page
    @step_by_step_page = create(:published_step_by_step_page)
    expect(@step_by_step_page.status).to be_published
  end

  def given_there_is_a_published_step_by_step_page_with_unpublished_changes
    @step_by_step_page = create(:published_step_by_step_page, draft_updated_at: 1.day.ago, status: "draft")
    expect(@step_by_step_page.status).to be_draft
  end

  def given_I_am_assigned_to_a_published_step_by_step_page_with_unpublished_changes
    @step_by_step_page = create(:published_step_by_step_page, draft_updated_at: 1.day.ago, assigned_to: stub_user.name)
  end

  def given_there_is_a_scheduled_step_by_step_page
    @step_by_step_page = create(:scheduled_step_by_step_page)
    expect(@step_by_step_page.status).to be_scheduled
  end

  def given_there_is_a_step_by_step_page_with_a_link_report
    link_checker_api_get_batch(
      id: 1,
      links: [link_checker_api_link_report_success]
    )

    step = create(:step)
    create(:link_report, step_id: step.id)
    @step_by_step_page = create(:step_by_step_page, steps: [step], slug: "step-by-step-with-link-report")
  end

  alias_method :given_there_is_a_step_that_has_no_broken_links, :given_there_is_a_step_by_step_page_with_a_link_report

  def given_there_is_a_step_by_step_page_with_unpublished_changes_whose_links_have_been_checked
    link_checker_api_get_batch(id: 1, links: [link_checker_api_link_report_success])
    step = create(:step)
    create(:link_report, step_id: step.id)
    @step_by_step_page = create(:step_by_step_with_unpublished_changes, steps: [step], slug: 'step-by-step-with-unpublished-changes')
  end

  def given_a_step_by_step_has_been_updated_after_links_last_checked
    link_checker_api_get_batch(id: 1, links: [link_checker_api_link_report_success])
    step = create(:step)
    create(:link_report, step_id: step.id)
    @step_by_step_page = create(
      :step_by_step_with_unpublished_changes,
      steps: [step],
      slug: 'step-by-step-with-recent-unpublished-changes',
      draft_updated_at: Time.zone.now
    )
  end

  def given_a_step_by_step_has_an_empty_step_added_after_links_last_checked
    link_checker_api_get_batch(id: 1, links: [link_checker_api_link_report_success])
    @step_by_step_page = create(
      :step_by_step_with_unpublished_changes,
      slug: 'step-by-step-with-link-report-and-empty-step-added-since-links-checked',
      draft_updated_at: Time.zone.now
    )

    step_with_link_report = create(:step, step_by_step_page: @step_by_step_page)
    create(:link_report, step_id: step_with_link_report.id)
    create(:step, contents: "", step_by_step_page: @step_by_step_page)
  end

  def given_there_is_a_draft_step_by_step_page_with_secondary_content_and_navigation_rules
    @step_by_step_page = create(:step_by_step_page_with_secondary_content_and_navigation_rules)
    expect(@step_by_step_page.status).to be_draft
  end

  def given_there_is_a_step_by_step_page_with_steps_missing_content
    @step_by_step_page = create(:draft_step_by_step_page)
    create(:step, step_by_step_page: @step_by_step_page, contents: "")
  end

  def given_there_are_step_by_step_pages
    @step_by_step_pages = [
      create(:draft_step_by_step_page, title: "A draft step nav", slug: "a-draft-step-nav"),
      create(:published_step_by_step_page, title: "A published step nav", slug: "a-published-step-nav")
    ]
  end

  def given_there_is_a_step_that_has_not_been_tested_for_broken_links
    @step_by_step_page = create(:step_by_step_page)
    create(:step, step_by_step_page: @step_by_step_page)
  end

  def given_there_is_a_step_with_a_broken_link
    @step_by_step_page = create(:step_by_step_page)
    step = create(:step, step_by_step_page: @step_by_step_page)
    link_checker_api_get_batch(
      id: 1,
      links: [link_checker_api_link_report_fail]
    )
    create(:link_report, step_id: step.id)
  end

  def given_there_is_a_step_with_multiple_broken_links
    @step_by_step_page = create(:step_by_step_page)
    step = create(:step, step_by_step_page: @step_by_step_page)
    link_checker_api_get_batch(
      id: 1,
      links: [link_checker_api_link_report_fail, link_checker_api_link_report_fail]
    )
    create(:link_report, step_id: step.id)
  end

  def link_checker_api_link_report_success
    {
      "uri": "https://www.gov.uk/",
      "status": "ok",
      "checked": "2017-04-12T18:47:16Z",
      "errors": [],
      "warnings": [],
      "problem_summary": "null",
      "suggested_fix": "null"
    }
  end

  def link_checker_api_link_report_fail
    {
      "uri": "https://www.gov.uk/foo",
      "status": "broken"
    }
  end

  def then_I_can_see_a_success_message(message)
    within('.gem-c-success-alert') do
      expect(page).to have_content message
    end
  end
end
