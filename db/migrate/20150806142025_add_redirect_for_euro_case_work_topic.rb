class AddRedirectForEuroCaseWorkTopic < ActiveRecord::Migration
  def up
    redirect_item = {
      "format" => "redirect",
      "publishing_app" => "collections-publisher",
      "update_type" => "major",
      "redirects" => [
        {
          "path" => "/immigration-operational-guidance/european-casework-instructions",
          "type" => "exact",
          "destination" => "/collections/eea-swiss-nationals-and-ec-association-agreements-modernised-guidance",
        },
      ],
    }

    publishing_api = CollectionsPublisher.services(:publishing_api)
    resp = publishing_api.put_content_item("/immigration-operational-guidance/european-casework-instructions", redirect_item)
    puts resp.body
  end

  def down
  end
end
