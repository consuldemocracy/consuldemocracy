class Officing::VotersController < Officing::BaseController
  respond_to :html, :js

  def new
    @user = User.find(params[:id])
    @polls = Poll.incoming # fix and use answerable_by(@user)
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

  def vote_with_tablet
    sign_in_voter
    redirect_to new_officing_poll_nvote_path(Poll.incoming.first)
  end

  private

    def voter_params
      params.require(:voter).permit(:poll_id, :user_id)
    end

    def sign_in_voter
      @voter = User.find(params[:id])
      session[:officer_email] = current_user.email
      sign_out(:user)
      sign_in(@voter)
    end
end