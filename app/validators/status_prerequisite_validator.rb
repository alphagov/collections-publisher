class StatusPrerequisiteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == "scheduled"
      return true if can_be_scheduled?(record)

      record.errors[attribute] << "#{value}, requires a draft and scheduled_at date to be present"
    end

    if value == "submitted_for_2i"
      return true if can_be_submitted_for_2i?(record)

      record.errors[attribute] << "#{value}, requires a draft and review_requester_id to be present"
    end
  end

private

  def can_be_scheduled?(record)
    record.has_draft? && record.scheduled_at.present?
  end

  def can_be_submitted_for_2i?(record)
    record.has_draft? && record.review_requester_id.present?
  end
end
