class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true
  has_many :link_report

  def broken_links
    collect_broken_links unless most_recent_batch.nil?
  end

  def request_broken_links
    LinkReport.new(step_id: self.id).create_batch
  end

private

  def collect_broken_links
    batch_link_report.links.keep_if do |link|
      link.fetch('status') == 'broken'
    end
  end

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
