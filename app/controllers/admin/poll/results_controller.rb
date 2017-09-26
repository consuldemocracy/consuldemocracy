class Admin::Poll::ResultsController < Admin::Poll::BaseController
  before_action :load_poll

  def index
    @partial_results = @poll.partial_results
  end

  private

    def load_poll
      @poll = ::Poll.includes(:questions).find(params[:poll_id])
    end
end
