class Officing::NvotesController < Officing::BaseController
  load_and_authorize_resource :nvote, class: "Poll::Nvote"

  skip_before_action :verify_officer

  layout "nvotes"

  def new
    @polls = Poll.current
    @poll = Poll.find(params[:poll_id])
  end

  def thanks
    @polls = Poll.current
  end

  private

    def load_nvote
      @nvote = current_user.get_or_create_nvote(@poll)
    end
end