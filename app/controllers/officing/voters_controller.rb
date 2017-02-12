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
                             poll: @poll,
                             origin: "booth")
    @voter.save!
  end

  def vote_with_tablet
    @voter = User.find(params[:id])
    votable_polls = Poll.votable_by(@voter)

    prepopulate_nvotes(@voter, current_user, votable_polls)
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

    def prepopulate_nvotes(voter, officer, votable_polls)
      votable_polls.with_nvotes.sort_for_list.each do |poll|
        officer_assignment = ::Poll::OfficerAssignment.by_officer(officer)
                                                      .by_poll(poll)
                                                      .by_date(Date.current)
                                                      .first

        voter.get_or_create_nvote(poll, officer_assignment)
      end
    end
end
