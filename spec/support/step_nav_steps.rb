module StepNavSteps
  def setup_publishing_api
    stub_any_publishing_api_put_content
    stub_any_publishing_api_discard_draft
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(StepNavPublisher).to receive(:lookup_content_ids).and_return(
      '/good/stuff' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e1',
      '/also/good/stuff' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e2',
      '/not/as/great' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e3'
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

  def then_the_page_is_published
    payload = StepNavPresenter.new(@step_by_step_page).render_for_publishing_api
    stub_publishing_api_put_content_links_and_publish(payload, @step_by_step_page.content_id)
  end

  def then_the_page_is_unpublished
    assert_publishing_api_unpublish(@step_by_step_page.content_id)
  end

  def expect_update_worker
    allow(StepByStepDraftUpdateWorker).to receive(:perform_async).with(@step_by_step_page.id)
  end

  def given_there_is_a_step_by_step_page_with_steps
    @step_by_step_page = create(:step_by_step_page_with_steps)
  end

  def given_there_is_a_step_by_step_page
    @step_by_step_page = create(:step_by_step_page)
  end
end
