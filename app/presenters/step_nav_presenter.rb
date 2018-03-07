class StepNavPresenter
  def initialize(step_nav)
    @step_nav = step_nav
  end

  def render_for_publishing_api
    required_fields
  end

private
  attr_reader :step_nav

  def required_fields
    {
      title: step_nav.title,
      base_path: base_path,
      description: step_nav.description,
      schema_name: "step_by_step_nav",
      document_type: "step_by_step_nav",
      need_ids: [],
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      redirects: [],
      update_type: "minor",
      details: details,
      locale: "en"
    }
  end

  def base_path
    "/#{step_nav.slug}"
  end

  def public_updated_at
    step_nav.updated_at.to_datetime.rfc3339(3)
  end

  def routes
    [{ path: "#{base_path}", type: 'exact' }]
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
    step_content_parser = StepContentParser.new

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
end
