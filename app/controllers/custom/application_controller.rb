require_dependency Rails.root.join("app", "controllers", "application_controller").to_s

class ApplicationController < ActionController::Base
  before_action :check_iframe
  after_action :set_iframe
  def set_default_budget_filter
    if @budget&.balloting? || @budget&.publishing_prices? || @budget&.reviewing_ballots? || @budget&.finished?
      params[:filter] ||= "selected"
    end
  end
  private
    def check_iframe
      if params[:iframed]
        session[:iframed] = true
      end
    end
    def set_iframe
      if(Rails.application.config.respond_to?(:participacion_push_target_origin))
        response.set_header("Content-Security-Policy", "frame-ancestors 'self' "+Rails.application.config.participacion_push_target_origin+";")
      end

    end

end
