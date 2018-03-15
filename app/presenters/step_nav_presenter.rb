class StepNavPresenter
  def initialize(step_nav)
    @step_nav = step_nav
    @step_content_parser = StepContentParser.new
  end

  def render_for_publishing_api
    required_fields
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
      need_ids: [],
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      redirects: [],
      rendering_app: "collections",
      routes: routes,
      schema_name: "step_by_step_nav",
      title: step_nav.title,
      update_type: "minor",
    }
  end

  def base_path
    "/#{step_nav.slug}"
  end

  def public_updated_at
    step_nav.updated_at.to_datetime.rfc3339(3)
  end

  def routes
    [{ path: base_path, type: 'exact' }]
  end

  def details
    {
      step_by_step_nav: {
        title: step_nav.title,
        introduction: [
          {
            content_type: "text/govspeak",
            content: step_nav.introduction
          }
        ],
        steps: steps
      }
    }
  end

  def steps
    step_nav.steps.map do |step|
      {
        title: step.title,
        contents: step_content_parser.parse(step.contents),
      }.tap do |optional_content|
        optional_content[:optional] = !! step.optional # if it's nil return false.
        optional_content[:logic] = step.logic if %w(and or).include?(step.logic)
      end
    end
  end

  def edition_links
    {
      "pages_part_of_step_nav": parsed_edition_links
    }
  end

  def parsed_edition_links
    StepNavPublisher.lookup_content_ids(parsed_base_paths).values
  end

  def parsed_base_paths
    step_nav.steps.map { |step| step_content_parser.base_paths(step.contents) }.flatten.uniq
  end
end
