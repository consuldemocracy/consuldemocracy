class SDGManagement::BaseController < ApplicationController
  include FeatureFlags
  feature_flag :sdg

  layout "admin"

  before_action :authenticate_user!
  before_action :verify_sdg_manager

  skip_authorization_check

  private

    def verify_sdg_manager
      raise CanCan::AccessDenied unless current_user&.sdg_manager? || current_user&.administrator?
    end
end
