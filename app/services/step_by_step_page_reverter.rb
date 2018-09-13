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

    step_by_step_page.steps = steps

    add_navigation_rules
  end

private

  def step_by_step_nav_details
    payload_from_publishing_api[:details][:step_by_step_nav]
  end

  def introduction
    contents = step_by_step_nav_details[:introduction].map { |line| line[:content] }
    contents.join(" ")
  end

  def steps
    steps_in_step_by_step = step_by_step_nav_details[:steps]
    new_steps = steps_in_step_by_step.map.with_index do |step, index|
      Step.new(
        title: step[:title],
        logic: logic(step),
        optional: step[:optional],
        position: index + 1,
        contents: contents(step[:contents]),
      )
    end

    new_steps
  end

  def logic(step)
    step[:logic] || "number"
  end

  def contents(step_contents)
    contents_list = step_contents.map do |content|
      next bulleted_list(content) if bulleted_list?(content)
      next list(content) if list?(content[:type])
      content[:text]
    end

    contents_list.join("\r\n\r\n")
  end

  def bulleted_list?(content)
    list?(content[:type]) && content[:style].present? && content[:style] == "choice"
  end

  def bulleted_list(contents)
    list = contents[:contents].map do |content|
      next "- #{link(content)}" + context(content) if link?(content)
      "- #{content[:text]}"
    end

    list.join("\r\n")
  end

  def list?(type)
    type == "list"
  end

  def list(contents)
    list = contents[:contents].map do |content|
      link(content) + context(content)
    end

    list.join("\r\n")
  end

  def link?(content)
    content[:href].present?
  end

  def link(content)
    "[#{content[:text]}](#{content[:href]})"
  end

  def context(content)
    content[:context].present? ? " #{content[:context]}" : ""
  end

  def add_navigation_rules
    StepLinksForRules.update(step_by_step_page)
  end
end
