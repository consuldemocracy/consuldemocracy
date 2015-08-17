class StatsController < ApplicationController
  def show
    @event_types = Ahoy::Event.select(:name).uniq.pluck(:name)
  end
end
