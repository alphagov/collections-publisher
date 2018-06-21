class PublishOrganisationsApiRoute
  def publish
    payload = present_for_publishing_api
    Services.publishing_api.put_content(payload[:content_id], payload[:content])
    Services.publishing_api.publish(payload[:content_id], nil, locale: "en")
  end

private

  BASE_PATH = "/api/organisations".freeze
  CONTENT_ID = "6848a0b0-8cd0-4641-ac3f-5e70379be309".freeze

  def present_for_publishing_api
    {
      content_id: CONTENT_ID,
      content: {
        title: "Organisations API",
        description: "API exposing all organisations on GOV.UK.",
        document_type: "special_route",
        schema_name: "special_route",
        locale: "en",
        base_path: BASE_PATH,
        publishing_app: "collections-publisher",
        rendering_app: "collections",
        routes: [
          {
            path: BASE_PATH,
            type: "prefix",
          },
        ],
        public_updated_at: Time.zone.now.iso8601,
        update_type: "minor",
      }
    }
  end
end
