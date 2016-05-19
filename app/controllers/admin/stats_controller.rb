class Admin::StatsController < Admin::BaseController

  def show
    @event_types = Ahoy::Event.pluck(:name).uniq.sort

    @visits = Visit.count
    @debates = Debate.with_hidden.count
    @proposals = Proposal.with_hidden.count
    @spending_proposals = SpendingProposal.with_hidden.count
    @comments = Comment.with_hidden.count
    @ballot_lines = BallotLine.count

    @debate_votes = Vote.where(votable_type: 'Debate').count
    @proposal_votes = Vote.where(votable_type: 'Proposal').count
    @spending_proposal_votes = Vote.where(votable_type: 'SpendingProposal').count
    @comment_votes = Vote.where(votable_type: 'Comment').count
    @votes = Vote.count

    @user_level_two = User.with_hidden.level_two_verified.count
    @user_level_three = User.with_hidden.level_three_verified.count
    @verified_users = User.with_hidden.level_two_or_three_verified.count
    @unverified_users = User.with_hidden.unverified.count
    @users = User.with_hidden.count
    @user_ids_who_voted_proposals =
     ActsAsVotable::Vote.where(votable_type: 'Proposal').pluck(:voter_id).uniq.count
    @user_ids_who_didnt_vote_proposals = @verified_users - @user_ids_who_voted_proposals
    @spending_proposals = SpendingProposal.count
    @ballots_with_votes = Ballot.where("ballot_lines_count > ?", 0).count
  end

  def graph
    @name = params[:id]
    @event = params[:event]

    if params[:event]
      @count = Ahoy::Event.where(name: params[:event]).count
    else
      @count = params[:count]
    end
  end

  def spending_proposals
    @ballots = Ballot.group(:geozone).count
    @user_count = Ballot.where('ballot_lines_count > ?', 0).count
  end

end
