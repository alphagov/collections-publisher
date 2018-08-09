class LinkReport < ApplicationRecord
  belongs_to :step

  def batch_links
    @step = self.step
    parsed_content = StepContentParser.new.parse(@step.contents)
    links = generate_links(parsed_content)
    links.map! { |link| link[0..4] == "http:" ? link : prefix_govuk(link) }
  end

  def create_batch
    batch = Services.link_checker_api.create_batch(batch_links)
    self.batch_id = batch.id
    self.save
  end

private
  
  def list_contents(list_contents)
    list_contents.map { |content_item| content_item.fetch(:href) }
  end

  def prefix_govuk(path_to_prefix)
    "https://www.gov.uk" + path_to_prefix    
  end

  def generate_links(parsed_content)
    links = []
    parsed_content.each do |content|
      links << list_contents(content.fetch(:contents)) unless content.fetch(:type, nil) != 'list'
    end
    links.flatten!
  end
end
