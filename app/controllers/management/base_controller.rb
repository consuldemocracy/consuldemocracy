class Management::BaseController < ActionController::Base
  layout 'management'

  before_action :verify_manager

  private

    def verify_manager
      raise ActionController::RoutingError.new('Not Found') unless current_manager.present?
    end

    def current_manager
      @current_manager ||= Manager.find(session["manager_id"]) if session["manager_id"]
    end

    def current_user
      @current_user ||= User.find(session["managed_user_id"]) if session["managed_user_id"]
    end

    def set_managed_user(user)
      session["managed_user_id"] = user.id
    end

end
