class Polls::StatsController < ApplicationController
  
  before_action :load_poll
  load_and_authorize_resource :poll
    
  def show
    authorize! :read_stats, @poll
    @stats = load_stats
  end
  
  private
  
    def load_stats
      Poll::Stats.new(@poll).generate
    end
  
    def load_poll
      @poll = Poll.find_by(id: params[:id])
    end
end