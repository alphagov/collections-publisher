class ListsController < ApplicationController
  before_action :find_tag
  before_action :find_list, except: %i[new create]
  before_action :require_gds_editor_permissions_to_edit_browse_pages!

  def show; end

  def new
    @list = List.new
  end

  def edit
    @list = @tag.lists.find(params[:id])
  end

  def create
    @list = @tag.lists.build(list_params)
    @list.index = (@tag.lists.maximum(:index) || 0) + 1

    if @list.save
      ListPublisher.new(@tag).perform
      flash[:notice] = "#{@list.name} list created"

      redirect_to polymorphic_path(@tag)
    else
      render :new
    end
  end

  def confirm_destroy; end

  def destroy
    @list.destroy!

    if @list.destroyed?
      ListPublisher.new(@tag).perform
      flash[:notice] = "#{@list.name} list deleted"
    else
      flash[:alert] = "Could not delete the list"
    end

    redirect_to polymorphic_path(@tag)
  end

  def update
    if @list.update(list_params)
      ListPublisher.new(@tag).perform
      flash[:notice] = "#{@list.name} list updated"

      redirect_to polymorphic_path(@tag)
    else
      render :edit
    end
  end

  def edit_list_items; end

  def update_list_items
    @available_list_items = @list.available_list_items

    if save_list_items
      ListPublisher.new(@tag).perform
      flash[:notice] = "#{helpers.pluralize(edit_list_items_params.count, 'link')} successfully added to the list"

      redirect_to tag_list_path(@tag, @list)
    else
      render :edit_list_items
    end
  end

  def manage_list_item_ordering; end

  def update_list_item_ordering
    save_ordering
    ListPublisher.new(@tag).perform
    flash["notice"] = "List links reordered successfully"

    redirect_to tag_list_path(@tag, @list)
  end

private

  def find_list
    @list = @tag.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name, :index)
  end

  def edit_list_items_params
    params.dig(:list, :list_items)
  end

  def save_list_items
    @list.errors.add(:list_items, "Select a link to add to the list") and return false if edit_list_items_params.blank?

    edit_list_items_params.each do |content_id|
      linked_item = @available_list_items.select { |item| item.content_id == content_id }.first
      @list.list_items.create!(
        base_path: linked_item.base_path,
        content_id: linked_item.content_id,
        title: linked_item.title,
        index: @list.list_items.length + 1,
      )
    end
  end

  def save_ordering
    params[:ordering].each do |link_order|
      id, index = link_order
      list_item = @list.list_items.find(id)
      list_item.update!(index:)
    end
  end
end
