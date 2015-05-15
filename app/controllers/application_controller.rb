class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include GDS::SSO::ControllerMethods
  before_filter :require_signin_permission!

  private

  def require_gds_editor_permissions!
    authorise_user!("GDS Editor")
  end

  def find_topic
    @topic = Topic.find_by!(content_id: params[:sector_id])
  end
end
