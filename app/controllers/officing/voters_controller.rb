class Officing::VotersController < Officing::BaseController
  respond_to :html, :js

  before_action :load_officer_assignment
  before_action :verify_officer_assignment
  before_action :verify_booth

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
                             officer: current_user.poll_officer,
                             booth_assignment: Poll::BoothAssignment.where(poll: @poll, booth: current_booth).first,
                             officer_assignment: officer_assignment(@poll))
    @voter.save!
  end

  private

    def voter_params
      params.require(:voter).permit(:poll_id, :user_id)
    end

    def officer_assignment(poll)
      Poll::OfficerAssignment.by_officer(current_user.poll_officer)
                             .by_poll(poll)
                             .by_booth(current_booth)
                             .by_date(Date.current)
                             .where(final: false)
                             .first
    end

end
