require_dependency Rails.root.join("app", "controllers", "application_controller").to_s

class ApplicationController < ActionController::Base
  def set_default_budget_filter
    if @budget&.balloting? || @budget&.publishing_prices? || @budget&.reviewing_ballots? || @budget&.finished?
      params[:filter] ||= "selected"
    end
  end
end
