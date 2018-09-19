module PublishingApiHelper
  # state_history returns a hash like {"3"=>"draft", "2"=>"published", "1"=>"superseded"}
  # so we need to get the highest value for a key.
  def latest_edition_number(content_id, publication_state: "")
    latest_content_item = content_item(content_id)

    if publication_state.present?
      version = latest_content_item[:state_history].select { |_, hash| hash[publication_state] }
      return version.keys.first.to_i
    end

    latest_content_item[:state_history].keys.max.to_i
  end

  def content_item(content_id)
    Services.publishing_api.get_content(content_id)
  end
end
