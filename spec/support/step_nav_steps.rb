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

  def given_there_is_a_step_by_step_page_with_steps
    @step_by_step_page = create(:step_by_step_page_with_steps)
  end

  def given_there_is_a_step_by_step_page_with_navigation_rules
    @step_by_step_page = create(:step_by_step_page_with_navigation_rules)
  end

  def given_there_is_a_draft_step_by_step_page
    @step_by_step_page = create(:draft_step_by_step_page)
    expect(@step_by_step_page.status).to eq 'draft'
  end

  def given_there_is_a_published_step_by_step_page
    @step_by_step_page = create(:published_step_by_step_page)
    expect(@step_by_step_page.status).to eq 'published'
  end

  def given_there_is_a_published_step_by_step_page_with_unpublished_changes
    @step_by_step_page = create(:published_step_by_step_page, draft_updated_at: Time.zone.now)
    expect(@step_by_step_page.status).to eq 'unpublished_changes'
  end

  def given_I_am_assigned_to_a_published_step_by_step_page_with_unpublished_changes
    @step_by_step_page = create(:published_step_by_step_page, draft_updated_at: Time.zone.now, assigned_to: stub_user.name)
  end

  def given_there_is_a_scheduled_step_by_step_page
    @step_by_step_page = create(:scheduled_step_by_step_page)
    expect(@step_by_step_page.status).to eq 'scheduled'
  end

  def given_there_is_a_step_by_step_page_with_a_link_report
    link_checker_api_get_batch(
      id: 1,
      links: [
        {
          "uri": "https://www.gov.uk/",
          "status": "ok",
          "checked": "2017-04-12T18:47:16Z",
          "errors": [],
          "warnings": [],
          "problem_summary": "null",
          "suggested_fix": "null"
        }
      ]
    )

    step = create(:step)
    create(:link_report, step_id: step.id)
    @step_by_step_page = create(:step_by_step_page, steps: [step], slug: "step-by-step-with-link-report")
  end

  def given_there_is_a_draft_step_by_step_page_with_secondary_content_and_navigation_rules
    @step_by_step_page = create(:step_by_step_page_with_secondary_content_and_navigation_rules, draft_updated_at: 1.day.ago)
    expect(@step_by_step_page.status).to eq 'draft'
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
end
