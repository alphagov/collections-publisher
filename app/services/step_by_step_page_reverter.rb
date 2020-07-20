class StepByStepPageReverter
  attr_reader :step_by_step_page, :payload_from_publishing_api

  def initialize(step_by_step_page, payload_from_publishing_api)
    @step_by_step_page = step_by_step_page
    @payload_from_publishing_api = payload_from_publishing_api.with_indifferent_access
  end

  def repopulate_from_publishing_api
    step_by_step_page.update!(
      title: title,
      slug: slug,
      introduction: introduction,
      description: description,
      draft_updated_at: step_by_step_page.published_at,
      status: "published",
    )

    step_by_step_page.steps = steps
    step_by_step_page.secondary_content_links = secondary_content_links

    add_navigation_rules
  end

private

  def title
    payload_from_publishing_api[:title]
  end

  def slug
    payload_from_publishing_api[:base_path].tr("/", "")
  end

  def description
    payload_from_publishing_api[:description]
  end

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
        optional: nil,
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
    StepLinksForRules.call(step_by_step_page)

    set_navigation_states
  end

  def set_navigation_states
    step_by_step_page.navigation_rules.each do |rule|
      rule.update!(include_in_links: "conditionally") if pages_related_to_step_nav.include?(rule.content_id)
      rule.update!(include_in_links: "never") unless pages_part_of_or_related_to_step_nav.include?(rule.content_id)
    end
  end

  def secondary_content_links
    @secondary_content_links ||= pages_secondary_to_step_nav.map do |content_id|
      content_item = Services.publishing_api.get_content(content_id)

      SecondaryContentLink.new(
        base_path: content_item["base_path"],
        title: content_item["title"],
        content_id: content_id,
        publishing_app: content_item["publishing_app"],
        schema_name: content_item["schema_name"],
      )
    end
  end

  def pages_related_to_step_nav
    payload_from_publishing_api[:links][:pages_related_to_step_nav] || []
  end

  def pages_part_of_or_related_to_step_nav
    (payload_from_publishing_api[:links][:pages_part_of_step_nav] || []) +
      (payload_from_publishing_api[:links][:pages_related_to_step_nav] || [])
  end

  def pages_secondary_to_step_nav
    payload_from_publishing_api[:links][:pages_secondary_to_step_nav] || []
  end
end
