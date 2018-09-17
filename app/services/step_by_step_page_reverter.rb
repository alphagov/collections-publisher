class StepByStepPageReverter
  attr_reader :step_by_step_page, :payload_from_publishing_api

  def initialize(step_by_step_page, payload_from_publishing_api)
    @step_by_step_page = step_by_step_page
    @payload_from_publishing_api = payload_from_publishing_api.with_indifferent_access
  end

  def repopulate_from_publishing_api
    step_by_step_page.title = payload_from_publishing_api[:title]
    step_by_step_page.slug = payload_from_publishing_api[:base_path].tr('/', '')
    step_by_step_page.introduction = introduction
    step_by_step_page.description = payload_from_publishing_api[:description]
    step_by_step_page.draft_updated_at = step_by_step_page.published_at

    step_by_step_page.save!
  end

private

  def step_by_step_nav_details
    payload_from_publishing_api[:details][:step_by_step_nav]
  end

  def introduction
    contents = step_by_step_nav_details[:introduction].map { |line| line[:content] }
    contents.join(" ")
  end
end
