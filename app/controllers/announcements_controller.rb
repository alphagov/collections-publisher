class AnnouncementsController < ApplicationController
  before_action :require_unreleased_feature_permissions!
  before_action :require_coronavirus_editor_permissions!
end
