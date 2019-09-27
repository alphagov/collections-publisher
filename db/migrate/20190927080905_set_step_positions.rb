class SetStepPositions < ActiveRecord::Migration[5.2]
  def change
    StepByStepPage.all.each do |step_by_step_page|
      # Assumption: all step by steps `steps` array are in order, whether they have a `position` or not
      # This is the same logic as relied upon in show.html
      step_by_step_page.steps.each.with_index(1) do |step, index|
        step.update_attributes!(position: index)
      end
    end
  end
end
