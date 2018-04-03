class StepLinksForRules
  def initialize(step_by_step_page:, step_content_parser: StepContentParser.new)
    @step_by_step_page = step_by_step_page
    @step_content_parser = step_content_parser
  end

  def call
    step_by_step_page.navigation_rules.each do |rule|
      rules_from_step_content[rule.content_id]["include_in_links"] = rule.include_in_links if rules_from_step_content[rule.content_id]
    end

    # clear out the existing rules
    delete_rules

    # replace with fresh rules
    add_rules(rules: rules_from_step_content.values)
  end

private

  attr_reader :step_content_parser, :step_by_step_page

  # hash of rules payloads keyed by content_id
  def rules_from_step_content
    @step_rules ||= content_items.each_with_object({}) do |content_item, items|
      payload = {
        content_id: content_item["content_id"],
        title: content_item["title"],
        base_path: content_item["base_path"],
        include_in_links: true
      }
      items[content_item["content_id"]] = payload
    end
  end

  def base_paths
    @base_paths ||=
      begin
        all_contents = step_by_step_page.steps.map(&:contents).join
        step_content_parser.base_paths(all_contents).uniq
      end
  end

  def content_ids
    return [] if base_paths.empty?

    unvalidated_base_paths = (base_paths - navigation_rule_paths)

    @content_ids ||= Services.publishing_api.lookup_content_ids(
      base_paths: unvalidated_base_paths,
      with_drafts: true,
      ).values
  end

  def content_items
    @content_items ||= content_ids.map do |content_id|
      Services.publishing_api.get_content(content_id)
    end
  end

  def navigation_rule_paths
    step_by_step_page.navigation_rules.pluck(&:base_path)
  end

  def delete_rules
    step_by_step_page.navigation_rules.delete_all
  end

  def add_rules(rules:)
    rules.each do |rule|
      step_by_step_page.navigation_rules.new(rule).save!
    end
  end
end
