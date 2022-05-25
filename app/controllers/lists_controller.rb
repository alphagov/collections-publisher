class ListsController < ApplicationController
  layout :get_layout
  before_action :find_tag
  before_action :require_gds_editor_permissions_to_edit_browse_pages!

  def index
    @lists = @tag.lists.ordered
    render "start_curating_lists" unless @lists.any?
  end

  def show
    @list = @tag.lists.find(params[:id])
  end

  def new
    @list = List.new
  end

  def edit
    @list = @tag.lists.find(params[:id])
    render "edit_legacy" unless redesigned_lists_permission?
  end

  def create
    @list = @tag.lists.build(list_params)
    @list.index = (@tag.lists.maximum(:index) || 0) + 1

    if redesigned_lists_permission?
      if @list.save
        ListPublisher.new(@tag).perform
        flash[:notice] = "List created"

        redirect_to polymorphic_path(@tag)
      else
        render :new
      end
    else
      if @list.save
        @tag.mark_as_dirty!
        flash[:success] = "List created"
      else
        flash[:danger] = "Could not create your list"
      end
      redirect_to tag_lists_path(@tag)
    end
  end

  def confirm_destroy
    @list = @tag.lists.find(params[:id])
  end

  def destroy
    list = @tag.lists.find(params[:id])
    list.destroy!

    if redesigned_lists_permission?
      if list.destroyed?
        ListPublisher.new(@tag).perform
        flash[:notice] = "List deleted"
      else
        flash[:alert] = "Could not delete the list"
      end

      redirect_to polymorphic_path(@tag)
    else
      if list.destroyed?
        @tag.mark_as_dirty!
        flash[:success] = "List deleted"
      else
        flash[:danger] = "Could not delete the list"
      end

      redirect_to tag_lists_path(@tag)
    end
  end

  def update
    @list = @tag.lists.find(params[:id])

    if redesigned_lists_permission?
      if @list.update(list_params)
        ListPublisher.new(@tag).perform
        flash[:notice] = "List updated"

        redirect_to polymorphic_path(@tag)
      else
        render :edit
      end
    else
      saved = @list.update(list_params)

      @tag.mark_as_dirty! if saved

      respond_to do |format|
        format.html do
          if saved
            flash[:success] = "List updated"
          else
            flash[:danger] = "Could not save your list"
          end

          redirect_to tag_lists_path(@tag)
        end
        format.js do
          if saved
            render json: { errors: [] }
          else
            render json: { errors: list.errors.to_json }, status: :unprocessable_entity
          end
        end
      end
    end
  end

  def edit_list_items
    @list = @tag.lists.find(params[:id])
  end

  def update_list_items
    @list = @tag.lists.find(params[:id])
    @available_list_items = @list.available_list_items

    if save_list_items
      ListPublisher.new(@tag).perform
      flash[:notice] = "Items added to list successfully"

      redirect_to tag_list_path(@tag, @list)
    else
      render :edit_list_items
    end
  end

  def manage_list_item_ordering
    @list = @tag.lists.find(params[:id])
  end

  def update_list_item_ordering
    @list = @tag.lists.find(params[:id])
    save_ordering
    ListPublisher.new(@tag).perform
    flash["notice"] = "List items reordered successfully"

    redirect_to tag_list_path(@tag, @list)
  end

private

  def get_layout
    if redesigned_lists_permission? && action_name.in?(%w[new create edit update confirm_destroy show edit_list_items update_list_items manage_list_item_ordering update_list_item_ordering])
      "design_system"
    else
      "legacy"
    end
  end

  def list_params
    params.require(:list).permit(:name, :index)
  end

  def edit_list_items_params
    params.dig(:list, :list_items)
  end

  def save_list_items
    @list.errors.add(:list_items, "Select a link to add to the list") and return false if edit_list_items_params.blank?

    edit_list_items_params.each do |base_path|
      linked_item = @available_list_items.select { |item| item.base_path == base_path }.first
      @list.list_items.create!(
        base_path: linked_item.base_path,
        title: linked_item.title,
        index: @list.list_items.length + 1,
      )
    end
  end

  def save_ordering
    params[:ordering].each do |link_order|
      id, index = link_order
      list_item = @list.list_items.find(id)
      list_item.update!(index: index)
    end
  end

  def active_navigation_item
    @tag.is_a?(MainstreamBrowsePage) ? "mainstream_browse_pages" : "topics"
  end
end
