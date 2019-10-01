module StepNavActionsHelper
  def can_submit_for_2i?(step_by_step_page, user)
    step_by_step_page.status.draft? &&
      user.has_permission?("Unreleased feature")
  end

  def can_review?(step_by_step_page, user)
    can_claim_first_review?(step_by_step_page, user) ||
      can_take_over_review?(step_by_step_page, user)
  end

  def can_submit_2i_review?(step_by_step_page, user)
    step_by_step_page.status.in_review? &&
      step_by_step_page.reviewer_id == user.uid &&
      user.has_permission?("Unreleased feature")
  end

private

  def can_claim_first_review?(step_by_step_page, user)
    step_by_step_page.status.submitted_for_2i? &&
      step_by_step_page.review_requester_id != user.uid &&
      user.has_permission?("Unreleased feature")
  end

  def can_take_over_review?(step_by_step_page, user)
    step_by_step_page.status.in_review? &&
      step_by_step_page.review_requester_id != user.uid &&
      step_by_step_page.reviewer_id != user.uid &&
      user.has_permission?("Unreleased feature")
  end
end
