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
  end

  def then_the_content_is_sent_to_publishing_api
    assert_publishing_api_put_content(@step_by_step_page.content_id)
  end

  def then_the_draft_is_discarded
    assert_publishing_api_discard_draft(@step_by_step_page.content_id)
  end

  def then_the_page_is_published
    payload = StepNavPresenter.new(@step_by_step_page).render_for_publishing_api
    stub_publishing_api_put_content_links_and_publish(payload, @step_by_step_page.content_id)
  end
end
