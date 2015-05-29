class TagsController < ApplicationController
  def republish
    tag = Tag.find_by!(content_id: params[:tag_id])
    authorise_user!("GDS Editor") if tag.is_a?(MainstreamBrowsePage)
    PublishingAPINotifier.send_to_publishing_api(tag)
    redirect_to :back
  end
end
