class Officing::VotersController < Officing::BaseController
  respond_to :html, :js

  def new
    @user = User.find(params[:id])
    booths = current_user.poll_officer.shifts.current.vote_collection.pluck(:booth_id).uniq
    @polls = Poll.answerable_by(@user).where(id: Poll::BoothAssignment.where(booth: booths).pluck(:poll_id).uniq)
  end

  def create
    @poll = Poll.find(voter_params[:poll_id])
    @user = User.find(voter_params[:user_id])
    @voter = Poll::Voter.new(document_type:   @user.document_type,
                             document_number: @user.document_number,
                             user: @user,
                             poll: @poll,
                             origin: "booth",
                             officer: current_user.poll_officer)
    @voter.save!
  end

  private

    def voter_params
      params.require(:voter).permit(:poll_id, :user_id)
    end

end
