class TagsController < ApplicationController
  before_action :find_tag
  before_action :require_gds_editor_permissions_to_edit_browse_pages!

  def publish_lists
    ListPublisher.new(@tag).perform
    redirect_back(fallback_location: root_path)
  end
end
