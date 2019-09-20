module NavigationSteps
  def when_I_visit_the_browse_pages_index
    visit mainstream_browse_pages_path
  end

  def and_I_visit_the_browse_pages_index
    when_I_visit_the_browse_pages_index
  end

  def when_I_visit_the_new_browse_page_form
    visit new_mainstream_browse_page_path
  end

  def when_I_visit_the_topics_index
    visit topics_path
  end

  def and_I_visit_the_topics_index
    when_I_visit_the_topics_index
  end

  def when_I_visit_the_new_topic_form
    visit new_topic_path
  end

  def when_I_visit_the_step_by_step_pages_index
    visit step_by_step_pages_path
  end

  def when_I_visit_the_new_step_by_step_form
    visit new_step_by_step_page_path
  end

  def when_I_visit_the_step_by_step_page
    visit step_by_step_page_path(@step_by_step_page)
  end
end
