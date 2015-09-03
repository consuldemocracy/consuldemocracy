class StatsController < ApplicationController
  before_action :verify_administrator
  skip_authorization_check

  def show
    @event_types = Ahoy::Event.select(:name).uniq.pluck(:name)
  end

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user.try(:administrator?)
    end
end
