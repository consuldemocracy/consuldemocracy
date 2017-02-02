class Officing::VotersController < Officing::BaseController
  respond_to :html, :js

  def new
    @user = User.find(params[:id])
    @polls = Poll.answerable_by(@user)
  end

  def create
    @poll = Poll.find(voter_params[:poll_id])
    @user = User.find(voter_params[:user_id])
    @voter = Poll::Voter.new(document_type:   @user.document_type,
                             document_number: @user.document_number,
                             user: @user,
                             poll: @poll)
    @voter.save!
  end

  private

    def voter_params
      params.require(:voter).permit(:poll_id, :user_id)
    end

end
