class TagsController < ApplicationController
  layout :get_layout
  before_action :find_tag
  before_action :require_gds_editor_permissions_to_edit_browse_pages!

  def publish_lists
    ListPublisher.new(@tag).perform
    redirect_back(fallback_location: root_path)
  end

  def manage_list_ordering; end

  def update_list_ordering
    params["ordering"].each do |list_order|
      id, index = list_order
      list = @tag.lists.find(id)
      list.update!(index: index)
    end

    ListPublisher.new(@tag).perform
    flash["notice"] = "Lists reordered successfully"

    redirect_to polymorphic_path(@tag)
  end

private

  def get_layout
    if redesigned_lists_permission? && action_name.in?(%w[manage_list_ordering update_list_ordering])
      "design_system"
    else
      "legacy"
    end
  end
end
