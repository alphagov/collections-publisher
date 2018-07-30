class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true
  has_many :link_check_report

  # returns true if there are broken links
  def broken_links?
    most_recent_link_check_report.present? && number_of_broken_links > 0
  end

  # returns an array of LinkReport objects if there are any with a broken status or an empty array if not
  def broken_links
    batch_link_report.links.keep_if do |link|
      link.fetch('status') == 'broken' 
    end
  end

private
  # returns a BatchReport object from the GDS API helper for the link-checker service
  def batch_link_report
    @batch_link_report ||= Services.link_checker_api.get_batch(batch_link_report_id)
  end

  # gets the most recent batch id for a step
  def batch_link_report_id
    most_recent_link_check_report.batch_id
  end

  def most_recent_link_check_report
    LinkCheckReport.where(step_id: self.id).last
  end

  def number_of_broken_links
    batch_link_report.totals.broken
  end
end
