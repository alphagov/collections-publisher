namespace :step_by_step do
  desc "Add a status to all current step by step pages"
  task :set_status => :environment do
    StepByStepPage.all.each do |step_by_step_page|
      if step_by_step_page.has_draft? && step_by_step_page.scheduled_at.present?
        step_by_step_page.update_attributes(status: "scheduled")
      elsif step_by_step_page.has_draft?
        step_by_step_page.update_attributes(status: "draft")
      elsif step_by_step_page.has_been_published?
        step_by_step_page.update_attributes(status: "published")
      else
        step_by_step_page.update_attributes(status: "draft")
      end
    end
  end
end
