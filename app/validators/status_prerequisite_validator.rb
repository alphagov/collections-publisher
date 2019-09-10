class StatusPrerequisiteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == "scheduled"
      return true if record.has_draft? && record.scheduled_at.present?

      record.errors[attribute] << "#{value}, requires a draft and scheduled_at date to be present"
    end

    if value == "submitted_for_2i"
      return true if record.has_draft? && record.review_requester.present?

      record.errors[attribute] << "#{value}, requires a draft and review_requester to be present"
    end
  end
end
