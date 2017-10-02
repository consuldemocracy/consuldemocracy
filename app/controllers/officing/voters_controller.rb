class Officing::VotersController < Officing::BaseController
  respond_to :html, :js
  helper_method :physical_booth?

  before_action :load_officer_assignment
  before_action :verify_officer_assignment
  before_action :verify_booth

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
                             poll: @poll,
                             #obsolete - officer_assignment: officer_assignment(@poll),
                             origin: "booth")
    @voter.save!
  end

  def vote_with_tablet
    @voter = User.find(params[:id])
    votable_polls = Poll.votable_by(@voter)

    prepopulate_nvotes(@voter, votable_polls)
    sign_in_as_voter(@voter)
    redirect_to new_officing_poll_nvote_path(votable_polls.first)
  end

  private

    def voter_params
      params.require(:voter).permit(:poll_id, :user_id)
    end

    def sign_in_as_voter(voter)
      session[:officer_email] = current_user.email
      sign_out(:user)
      sign_in(voter)
    end

    def prepopulate_nvotes(voter,votable_polls)
      votable_polls.with_nvotes.sort_for_list.each do |poll|
        voter.get_or_create_nvote(poll, officer_assignment(poll))
      end
    end

    def officer_assignment(poll)
      Poll::OfficerAssignment.by_officer(current_user.poll_officer)
                             .by_poll(poll)
                             .by_booth(current_booth)
                             .by_date(Date.current)
                             .first
    end

    def physical_booth?
      officer_assignment = ::Poll::OfficerAssignment.by_officer(current_user.poll_officer)
                                                    .by_date(Date.current)
                                                    .first

      officer_assignment.booth_assignment.booth.physical?
    end

end
