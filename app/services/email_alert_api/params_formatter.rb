module EmailAlertApi
  module ParamsFormatter
    # This is equivalent to code introduced into email alert frontend:
    # https://github.com/alphagov/email-alert-frontend/blob/main/app/services/subscriber_list_params/generate_single_page_list_params_service.rb
    # to handle subscriber lists with reverse links.
    # It will only be needed in here temporarily while we migrate specialist topics
    def document_collection_subscriber_list_params(content_item)
      {
        "url" => content_item.base_path,
        "title" => content_item.title,
        "content_id" => content_item.content_id,
        "description" => content_item.description,
      }.merge(document_collection_links(content_item))
    end

    def document_collection_links(content_item)
      return {} unless content_item.document_type == "document_collection"

      { "links" => { "document_collections" => [content_item.content_id] } }
    end

    def specialist_topic_subscriber_list_params(topic)
      topic.subscriber_list_search_attributes
    end
  end
end
