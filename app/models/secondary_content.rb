class SecondaryContent
  attr_reader :step_by_step_page

  def initialize(step_by_step_page)
    @step_by_step_page = step_by_step_page
  end

  def content_ids
    content_ids = []
    content_ids = content_ids_of_secondary_content if step_nav_has_secondary_content?
    content_ids
  end

private

  def step_nav_has_secondary_content?
    # learn-to-drive-a-car
    step_by_step_page.id == 3
  end

  def content_ids_of_secondary_content
    base_paths = [
      "/drink-drive-limit",
      "/speed-limits",
    ]

    StepNavPublisher.lookup_content_ids(base_paths).values
  end
end
