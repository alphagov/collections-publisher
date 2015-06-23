class TagsController < ApplicationController
  before_filter :find_tag
  before_filter :require_gds_editor_permissions_to_edit_browse_pages!

  def publish_lists
    ListPublisher.new(@tag).perform
    redirect_to :back
  end
end
