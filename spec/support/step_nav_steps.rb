module StepNavSteps
  def setup_publishing_api
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:discard_draft)
  end

  def then_the_content_is_sent_to_publishing_api
    expect(Services.publishing_api).to have_received(:put_content)
  end

  def then_the_draft_is_discarded
    expect(Services.publishing_api).to have_received(:discard_draft)
  end
end
