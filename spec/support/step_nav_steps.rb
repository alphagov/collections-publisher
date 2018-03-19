module StepNavSteps
  def setup_publishing_api
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:discard_draft)
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(StepNavPublisher).to receive(:lookup_content_ids).and_return(
      '/good/stuff' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e1',
      '/also/good/stuff' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e2',
      '/not/as/great' => 'fd6b1901d-b925-47c5-b1ca-1e52197097e3'
    )
  end

  def then_the_content_is_sent_to_publishing_api
    expect(Services.publishing_api).to have_received(:put_content)
  end

  def then_the_draft_is_discarded
    expect(Services.publishing_api).to have_received(:discard_draft)
  end
end
