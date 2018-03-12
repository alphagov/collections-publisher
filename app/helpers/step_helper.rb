module StepHelper
  def has_help_section?(step)
    !(step.optional_heading.blank? || step.optional_contents.blank?)
  end
end
