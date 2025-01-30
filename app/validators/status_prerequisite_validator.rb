class StatusPrerequisiteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == "approved_2i"
      return true if can_be_2i_approved?(record)

      record.errors.add(attribute, "#{value}, requires a draft, a reviewer and for status to be in_review, scheduled, published or approved_2i")
    end

    if value == "in_review"
      return true if can_be_in_review?(record)

      record.errors.add(attribute, "#{value}, requires a draft, a reviewer and for status to be submitted_for_2i or in_review")
    end

    if value == "scheduled"
      return true if can_be_scheduled?(record)

      record.errors.add(attribute, "#{value}, requires a draft and scheduled_at date to be present")
    end

    if value == "submitted_for_2i"
      return true if can_be_submitted_for_2i?(record)

      record.errors.add(attribute, "#{value}, requires a draft and review_requester_id to be present")
    end
  end

private

  def can_be_in_review?(record)
    record.has_draft? &&
      record.reviewer_id.present? &&

      %w[submitted_for_2i in_review].include?(record.status_was)
  end

  def can_be_scheduled?(record)
    record.has_draft? && record.scheduled_at.present?
  end

  def can_be_submitted_for_2i?(record)
    record.has_draft? && record.review_requester_id.present?
  end

  def can_be_2i_approved?(record)
    allowed_previous_statuses = %w[in_review scheduled published approved_2i]
    record.has_draft? && allowed_previous_statuses.include?(record.status_was)
  end
end
