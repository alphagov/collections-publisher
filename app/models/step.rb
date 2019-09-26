class Step < ApplicationRecord
  belongs_to :step_by_step_page
  validates_presence_of :step_by_step_page
  validates :title, :logic, presence: true
  has_many :link_reports, :dependent => :destroy
  after_create :set_step_position
  after_destroy :set_parent_step_positions

  def broken_links?
    broken_links.present? && broken_links.any?
  end

  def link_report?
    most_recent_batch.present?
  end

  def links_last_checked_date
    most_recent_batch.created_at if link_report?
  end

  def broken_links
    collect_broken_links unless most_recent_batch.nil?
  end

  def request_broken_links
    LinkReport.new(step_id: self.id).create_record
  end

private

  def collect_broken_links
    return [] if batch_link_report.blank?

    batch_link_report.links.keep_if do |link|
      link.fetch("status") == "broken"
    end
  end

  def batch_link_report
    begin
      @batch_link_report ||= Services.link_checker_api.get_batch(batch_link_report_id)
    rescue GdsApi::HTTPServerError, GdsApi::HTTPNotFound
      nil
    end
  end

  def batch_link_report_id
    most_recent_batch.batch_id
  end

  def most_recent_batch
    LinkReport.where(step_id: self.id).last
  end

  def set_step_position
    update!(position: step_by_step_page.steps.count)
  end

  def set_parent_step_positions
    step_by_step_page.make_step_positions_sequential
  end
end
