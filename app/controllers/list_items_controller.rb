class ListItemsController < ApplicationController
  before_action :find_tag
  before_action :find_list
  before_action :find_list_item
  before_action :require_gds_editor_permissions_to_edit_browse_pages!

  def destroy
    @list_item.destroy!
    ListPublisher.new(@tag).perform
    flash[:notice] = "#{@list_item.title} removed from list"

    redirect_to tag_list_path(@tag, @list)
  end

  def confirm_destroy; end

  def move; end

  def update_move
    @list_item.errors.add(:new_list_id, "Choose a list") if move_list_item_params.blank?
    render :move and return if @list_item.errors.present?

    new_list = @tag.lists.find(move_list_item_params)
    new_index = new_list.list_items.map(&:index).max.to_i + 1
    @list_item.update!(list: new_list, index: new_index)
    ListPublisher.new(@tag).perform
    flash[:notice] = "#{@list_item.title} moved to #{new_list.name} successfully"

    redirect_to tag_list_path(@tag, @list)
  end

private

  def find_list
    @list = @tag.lists.find(params[:list_id])
  end

  def find_list_item
    @list_item = @list.list_items.find(params[:id])
  end

  def list_item_params
    params.require(:list_item).permit(:title, :base_path, :index)
  end

  def move_list_item_params
    params.dig(:list_item, :new_list_id)
  end
end
