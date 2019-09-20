module LinkChecker
  def stub_link_checker_report_success(step)
    link_checker_api_get_batch(
      id: 1,
      links: [link_checker_api_link_report_success]
    )
    create(:link_report, step_id: step.id)
  end

  def stub_link_checker_report_broken_link(step)
    link_checker_api_get_batch(
      id: 1,
      links: [link_checker_api_link_report_fail]
    )
    create(:link_report, step_id: step.id)
  end

  def stub_link_checker_report_multiple_broken_links(step)
    link_checker_api_get_batch(
      id: 1,
      links: [link_checker_api_link_report_fail, link_checker_api_link_report_fail]
    )
    create(:link_report, step_id: step.id)
  end

  def link_checker_api_link_report_success
    {
      "uri": "https://www.gov.uk/",
      "status": "ok",
      "checked": "2017-04-12T18:47:16Z",
      "errors": [],
      "warnings": [],
      "problem_summary": "null",
      "suggested_fix": "null"
    }
  end

  def link_checker_api_link_report_fail
    {
      "uri": "https://www.gov.uk/foo",
      "status": "broken"
    }
  end
end
