class StatusPrerequisiteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == "scheduled"
      return true if record.has_draft? && record.scheduled_at.present?

      record.errors[attribute] << "#{value}, requires a draft and scheduled_at date to be present"
    end
  end
end
