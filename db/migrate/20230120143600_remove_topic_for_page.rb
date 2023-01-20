class RemoveTopicForPage < ActiveRecord::Migration[7.0]
  def change
    page = MainstreamBrowsePage.find_by(content_id: "0eef00df-cd70-4a77-8965-2a90af9616e2")
    if page
      page.topics = []
      page.save!
    end
  end
end
