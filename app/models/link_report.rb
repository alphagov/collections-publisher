class LinkReport < ApplicationRecord
  belongs_to :step

  def create_record
    batch_response = request_batch_of_links
    if request_batch_of_links.present?
      self.batch_id = batch_response.id
      self.save
    end
  end

private

  def batch_of_links
    StepContentParser.new.all_paths(self.step.contents)
  end

  def request_batch_of_links
    if batch_of_links.any?
      Services.link_checker_api.create_batch(
        batch_of_links,
        webhook_uri: Plek.new.external_url_for("collections-publisher") + "/link_report"
      )
    end
  end
end
