module StepNavActionsHelper
  def can_review?(step_by_step_page, user)
    step_by_step_page.status.submitted_for_2i? &&
      step_by_step_page.review_requester_id != user.uid
  end
end
