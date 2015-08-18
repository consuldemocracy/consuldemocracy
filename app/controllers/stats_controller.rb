class StatsController < ApplicationController
  skip_authorization_check
  before_action :verify_administrator

  def show
    @event_types = Ahoy::Event.select(:name).uniq.pluck(:name)
  end

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user.try(:administrator?)
    end
end
