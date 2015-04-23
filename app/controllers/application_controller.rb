class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods
  before_filter :require_signin_permission!

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  private

  def require_gds_editor_permissions!
    authorise_user!("GDS Editor")
  end

  # FIXME: clean this up when we're using content_ids in the URL.
  def find_topic_for_sector_id
    if params[:sector_id].include?('/')
      parent_slug, child_slug = params[:sector_id].split('/', 2)
      parent = Topic.find_by!(:slug => parent_slug)
      @topic = parent.children.find_by!(:slug => child_slug)
    else
      @topic = Topic.only_parents.find_by!(:slug => params[:sector_id])
    end
  end
end
