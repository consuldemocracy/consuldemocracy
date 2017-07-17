class Officing::NvotesController < Officing::BaseController
  authorize_resource :nvote, class: "Poll::Nvote"
  skip_before_action :verify_officer

  layout "nvotes"

  def new
    @polls = Poll.votable_by(current_user)
    @poll = @polls.find(params[:poll_id])
  end

  def thanks
    @polls = Poll.votable_by(current_user)
  end
end