class NavigationRulesController < ApplicationController
  before_action :require_gds_editor_permissions!
  before_action :set_step_by_step_page, only: %i(edit update)

  def edit
    @step_page.navigation_rules
  end

  def update
    navigation_rules = params.delete(:navigation_rules)

    navigation_rules.each_pair do |content_id, value|
      value = %w(true false).include?(value) ? value : false

      rule = @step_page.navigation_rules.find_by(content_id: content_id)
      rule.update_attribute(:include_in_links, value) if rule
    end

    redirect_to(
      step_by_step_page_navigation_rules_path(@step_page),
      notice: 'Your choices have been saved.'
    )
  end

private
  def set_step_by_step_page
    @step_page = StepByStepPage.find(params[:step_by_step_page_id])
  end
end
