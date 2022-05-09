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

private

  def get_layout
    if redesigned_lists_permission? && action_name.in?(%w[new create edit update confirm_destroy show])
      "design_system"
    else
      "legacy"
    end
  end

  def list_params
    params.require(:list).permit(:name, :index)
  end

  def active_navigation_item
    @tag.is_a?(MainstreamBrowsePage) ? "mainstream_browse_pages" : "topics"
  end
end
