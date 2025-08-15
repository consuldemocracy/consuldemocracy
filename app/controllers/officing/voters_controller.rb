class Officing::VotersController < Officing::BaseController
  respond_to :html, :js

  before_action :load_officer_assignment
  before_action :verify_officer_assignment
  before_action :verify_booth

  def new
    @user = User.find(params[:id])
    @polls = current_booth.polls.current
  end

  def create
    @poll = Poll.find(voter_params[:poll_id])
    @user = User.find(voter_params[:user_id])

    unless @poll.answerable_by?(@user)
      return redirect_to(officing_root_path, alert: t("officing.officers.show.cannot_vote"))
    end

    if @poll.voted_by?(@user) || @poll.user_has_an_online_ballot?(@user)
      return redirect_to(officing_root_path, alert: t("officing.officers.show.error_already_voted"))
    end

    @voter = Poll::Voter.create_with(
      document_type: @user.document_type,
      document_number: @user.document_number,
      origin: "booth",
      officer: current_user.poll_officer,
      booth_assignment: current_booth.booth_assignments.find_by(poll: @poll),
      officer_assignment: officer_assignment(@poll)
    ).find_or_create_by!(user: @user, poll: @poll)

    unless @voter.previously_new_record?
      return redirect_to(officing_root_path, alert: t("officing.officers.show.error_already_voted"))
    end

    redirect_to officing_root_path, notice: t("officing.officers.show.success")
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
                             .find_by(final: false)
    end
end
