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
    @user_ids_who_voted_proposals = ActsAsVotable::Vote.where(votable_type: 'Proposal').distinct.count(:voter_id)
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

  def proposal_notifications
    @proposal_notifications = ProposalNotification.all
    @proposals_with_notifications = @proposal_notifications.select(:proposal_id).distinct.count
  end

  def direct_messages
    @direct_messages = DirectMessage.count
    @users_who_have_sent_message = DirectMessage.select(:sender_id).distinct.count
  end

  def spending_proposals
    @ballots = Ballot.where.not(geozone_id: nil).group(:geozone).count
    @voters_in_city = BallotLine.select(:ballot_id).uniq.joins(:spending_proposal).where("spending_proposals.geozone_id" => nil).to_a.size
    @voters_in_district = @ballots.values.sum
    @user_count = Ballot.where('ballot_lines_count > ?', 0).count
  end

  def budget_investments
    votes = Vote.for_budget_investments(Budget::Investment.all)
    @vote_count = votes.count
    @participant_count = votes.select(:voter_id).distinct.count

    @voters_in_city = voters_in_heading(city_heading)
    @voters_in_district = voters_in_districts
    @user_count = voters

    @voters_in_heading = {}
    budget = Budget.last
    budget.headings.each do |heading|
      @voters_in_heading[heading] = voters_in_heading(heading)
    end
  end

  def redeemable_codes
    @users = User.where.not(redeemable_code: nil)
    @users_after_campaign = @users.where("verified_at >= ?", Date.new(2016, 6, 17).beginning_of_day).count
  end

  def user_invites
    user_invites_campaign = Campaign.where(track_id: "172943750183759812").first
    @user_invites = Ahoy::Event.where(name: :user_invite).count
    @clicked_email_link = Ahoy::Event.where(name: user_invites_campaign.name).count
    @clicked_signup_button = Ahoy::Event.where(name: :clicked_signup_button).count
  end

  def polls
    @polls = ::Poll.all
    @voters = ::Poll::Voter.all
    @participants = ::Poll::Voter.select(:user_id).distinct.count
  end

  private

  def voters_in_heading(heading)
    Vote.where(votable_type: 'Budget::Investment').
    includes(:budget_investment).
    where(budget_investments: {heading_id: heading.id}).
    select("votes.voter_id").distinct.count
  end

  def voters_in_districts
    Vote.where(votable_type: 'Budget::Investment').
    includes(:budget_investment).
    where.not(budget_investments: {heading_id: city_heading.id}).
    select("votes.voter_id").distinct.count
  end

  def voters
    Vote.where(votable_type: 'Budget::Investment').select(:voter_id).distinct.count
  end

  def city_heading
    Budget::Heading.where(name: "Toda la ciudad").first
  end

end
