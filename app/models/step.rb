class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true
  
  def broken_links
    if most_recent_batch.nil?
      []
    else
      batch_link_report.links.keep_if do |link|
        link.fetch('status') == 'broken'
      end
    end
  end

  private

  def batch_link_report
    @batch_link_report ||= Services.link_checker_api.get_batch(batch_link_report_id)
  end

  def batch_link_report_id
    most_recent_batch.batch_id
  end

  def most_recent_batch
    LinkReport.where(step_id: self.id).last
  end
end
