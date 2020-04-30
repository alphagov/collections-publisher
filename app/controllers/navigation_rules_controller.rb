class NavigationRulesController < ApplicationController
  layout "admin_layout"
  before_action :require_gds_editor_permissions!
  before_action :set_step_by_step_page, only: %i[edit update]

  def edit
    @step_by_step_page.navigation_rules
  end

  def update
    navigation_rules = params.delete(:navigation_rules)

    navigation_rules.each_pair do |content_id, value|
      value = %w[always conditionally never].include?(value) ? value : "always"

      rule = @step_by_step_page.navigation_rules.find_by(content_id: content_id)
      rule.update_attribute(:include_in_links, value) if rule
    end

    StepByStepDraftUpdateWorker.perform_async(@step_by_step_page.id)

    redirect_to(@step_by_step_page, notice: "Your navigation choices have been saved.")
  end

private

  def set_step_by_step_page
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])
  end
end
