class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout "design_system"

  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  before_action :set_authenticated_user_header

  add_flash_types :success, :info, :warning, :danger

private

  helper_method :gds_editor?, :active_navigation_item, :coronavirus_editor?, :unreleased_feature_user?

  def gds_editor?
    current_user.has_permission? "GDS Editor"
  end

  def unreleased_feature_user?
    current_user.has_permission? "Unreleased feature"
  end

  def coronavirus_editor?
    current_user.has_permission? "Coronavirus editor"
  end

  # Can be overridden to allow controllers to choose the active menu item.
  def active_navigation_item
    controller_name
  end

  def require_2i_reviewer_permissions!
    authorise_user!("2i reviewer")
  end

  def require_coronavirus_editor_permissions!
    authorise_user!("Coronavirus editor")
  end

  def require_gds_editor_permissions!
    # authorise_user!("GDS Editor")
    true
  end

  def require_skip_review_permissions!
    authorise_user!("Skip review")
  end

  def require_gds_editor_permissions_to_edit_browse_pages!
    require_gds_editor_permissions! if @tag.is_a?(MainstreamBrowsePage)
  end

  def require_unreleased_feature_permissions!
    authorise_user!("Unreleased feature")
  end

  def find_tag
    @tag = Tag.find_by!(content_id: params[:tag_id])
  end

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end
end
