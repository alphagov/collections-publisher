class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true
  has_many :link_check_report

  # returns true if there are broken links
  def broken_links?
    batch_link_report.totals.broken > 0
  end

  # returns a BatchReport object from the GDS API helper for the link-checker service
  def batch_link_report
    @batch_link_report ||= Services.link_checker_api.get_batch(batch_link_report_id)
  end

  # gets the most recent batch id for a step
  def batch_link_report_id
    LinkCheckReport.where(step_id: self.id).last.batch_id
  end

  # returns an array of LinkReport objects if there are any with a broken status or an empty array if not
  def broken_links
    batch_link_report.links.map do |link|
      link if link.status == 'broken'
    end
  end
end
