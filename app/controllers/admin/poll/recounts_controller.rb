class Admin::Poll::RecountsController < Admin::Poll::BaseController
  before_action :load_poll

  def index
    @booth_assignments = @poll.booth_assignments.
                              includes(:booth, :recounts, :voters).
                              order("poll_booths.name").
                              page(params[:page]).per(50)
  end

  private

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end
end
