class TagsController < ApplicationController
  before_filter :find_tag
  before_filter :require_gds_editor_permissions_to_edit_browse_pages!

  def republish
    PublishingAPINotifier.send_to_publishing_api(@tag)
    redirect_to :back
  end
end
