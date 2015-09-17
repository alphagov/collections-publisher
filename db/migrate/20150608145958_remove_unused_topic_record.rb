class RemoveUnusedTopicRecord < ActiveRecord::Migration
  def up
    remove_subtopic
    redirect_former_url
  end

  def down
  end

  def remove_subtopic
    subtopic ||= Topic.find_by(content_id: "4ad3f330-8041-4960-826b-54327b4026ca")
    subtopic.destroy if subtopic
  end

  def redirect_former_url
    publishing_api = Services.publishing_api
    resp = publishing_api.put_content_item("/immigration-operational-guidance/european-casework-instructions", redirect_item)
    puts resp.body
  end


  def redirect_item
    {
      "format" => "redirect",
      "publishing_app" => "collections-publisher",
      "update_type" => "major",
      "redirects" => [
        {
          "path" => "/immigration-operational-guidance/european-casework-instructions",
          "type" => "exact",
          "destination" => "/immigration-operational-guidance",
        },
      ],
    }
  end
end
