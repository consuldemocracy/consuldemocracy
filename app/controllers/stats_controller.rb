class StatsController < ApplicationController
  before_action :verify_administrator
  skip_authorization_check

  def show
    @event_types = Ahoy::Event.select(:name).uniq.pluck(:name)
    @debates_created_count = Ahoy::Event.where(name: 'debate_created').count
  end

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user.try(:administrator?)
    end
end
