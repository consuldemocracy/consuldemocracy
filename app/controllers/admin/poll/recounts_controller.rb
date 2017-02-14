class Admin::Poll::RecountsController < Admin::BaseController
  before_action :load_poll

  def index
    @booth_assignments = @poll.booth_assignments.includes(:recounts, :final_recounts)
  end

  private

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end
end