class StepNavPresenter
  def initialize(step_nav)
    @step_nav = step_nav
    @step_content_parser = StepContentParser.new
  end

  def render_for_publishing_api(publish_intent = PublishIntent.minor_update)
    payload = required_fields
    payload.merge!(optional_fields)
    payload.merge(publish_intent.present)
  end

  def scheduling_payload
    {
      publish_time: step_nav.scheduled_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
    }
  end

  def base_path
    "/#{step_nav.slug}"
  end

private

  attr_reader :step_nav, :step_content_parser

  def required_fields
    {
      base_path: base_path,
      description: step_nav.description,
      details: details,
      document_type: "step_by_step_nav",
      links: edition_links,
      locale: "en",
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      redirects: [],
      rendering_app: "collections",
      routes: routes,
      schema_name: "step_by_step_nav",
      title: step_nav.title,
    }
  end

  def optional_fields
    fields = {}
    fields[:auth_bypass_ids] = [step_nav.auth_bypass_id] if step_nav.has_draft?
    fields
  end

  def public_updated_at
    step_nav.updated_at.rfc3339(3)
  end

  def routes
    [{ path: base_path, type: "exact" }]
  end

  def details
    {
      step_by_step_nav: {
        title: step_nav.title,
        introduction: [
          {
            content_type: "text/govspeak",
            content: step_nav.introduction,
          },
        ],
        steps: steps,
      },
    }
  end

  def steps
    step_nav.steps.map do |step|
      {
        title: step.title,
        contents: step_content_parser.parse(step.contents),
      }.tap do |optional_content|
        optional_content[:logic] = step.logic if %w[and or].include?(step.logic)
      end
    end
  end

  def edition_links
    links = {}
    links[:pages_part_of_step_nav] = part_of_step_nav_links if part_of_step_nav_links.present?
    links[:pages_related_to_step_nav] = related_to_step_nav_links if related_to_step_nav_links.present?
    links[:pages_secondary_to_step_nav] = secondary_to_step_nav_links if secondary_to_step_nav_links.present?
    links
  end

  def part_of_step_nav_links
    step_nav.navigation_rules.part_of_content_ids + done_page_content_ids(base_paths_for_navigation_rules)
  end

  def related_to_step_nav_links
    step_nav.navigation_rules.related_content_ids
  end

  def secondary_to_step_nav_links
    step_nav.secondary_content_links.pluck(:content_id) + done_page_content_ids(base_paths_for_secondary_content_links)
  end

  def done_page_content_ids(base_paths)
    content_ids = []
    if base_paths.any?
      results = StepNavPublisher.lookup_content_ids(base_paths)
      content_ids = results.values if results.any?
    end

    content_ids
  end

  def done_page_base_path(page)
    return page.base_path + "/y" if page.smartanswer?

    "/done" + page.base_path
  end

  def base_paths_for_navigation_rules
    step_nav.navigation_rules.select { |rule| rule.include_in_links == "always" }.map do |rule|
      done_page_base_path(rule)
    end
  end

  def base_paths_for_secondary_content_links
    step_nav.secondary_content_links.map do |secondary_content_link|
      done_page_base_path(secondary_content_link)
    end
  end
end
