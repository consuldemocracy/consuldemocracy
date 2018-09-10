class Admin::StatsController < Admin::BaseController

  def show
    @event_types = Ahoy::Event.pluck(:name).uniq.sort

    @visits = Visit.count
    @debates = Debate.with_hidden.count
    @proposals = Proposal.with_hidden.count
    @comments = Comment.not_valuations.with_hidden.count
    @spending_proposals = SpendingProposal.with_hidden.count
    @ballot_lines = BallotLine.count

    @debate_votes = Vote.where(votable_type: 'Debate').count
    @proposal_votes = Vote.where(votable_type: 'Proposal').count
    @spending_proposal_votes = Vote.where(votable_type: 'SpendingProposal').count
    @comment_votes = Vote.where(votable_type: 'Comment').count
    @votes = Vote.count

    @user_level_two = User.active.level_two_verified.count
    @user_level_three = User.active.level_three_verified.count
    @verified_users = User.active.level_two_or_three_verified.count
    @unverified_users = User.active.unverified.count
    @users = User.active.count
    @user_ids_who_voted_proposals = ActsAsVotable::Vote.where(votable_type: 'Proposal').distinct.count(:voter_id)
    @user_ids_who_didnt_vote_proposals = @verified_users - @user_ids_who_voted_proposals
    @spending_proposals = SpendingProposal.count
    @ballots_with_votes = Ballot.where("ballot_lines_count > ?", 0).count
    budgets_ids = Budget.where.not(phase: 'finished').pluck(:id)
    @budgets = budgets_ids.size
    @investments = Budget::Investment.where(budget_id: budgets_ids).count
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

  def budgets
    @budgets = Budget.all
  end

  def budget_supporting
    @budget = Budget.find(params[:budget_id])
    heading_ids = @budget.heading_ids

    votes = Vote.where(votable_type: 'Budget::Investment').
            includes(:budget_investment).
            where(budget_investments: {heading_id: heading_ids})

    @vote_count = votes.count
    @user_count = votes.select(:voter_id).distinct.count

    @voters_in_city = voters_in_heading(@budget.city_heading) rescue 0
    @voters_in_district = voters_in_districts(@budget) rescue 0

    @voters_in_heading = {}
    @budget.headings.each do |heading|
      @voters_in_heading[heading] = voters_in_heading(heading)
    end
  end

  def budget_balloting
    @budget = Budget.find(params[:budget_id])

    budget_stats = Stat.hash("budget_#{@budget.id}_balloting_stats")
    @user_count = budget_stats['stats']['user_count']
    @vote_count = budget_stats['stats']['vote_count']
    @user_count_in_city = budget_stats['stats']['user_count_in_city']
    @user_count_in_district = budget_stats['stats']['user_count_in_district']
    @user_count_in_city_and_district = budget_stats['stats']['user_count_in_city_and_district']

    @vote_count_by_heading = budget_stats['vote_count_by_heading']
    @user_count_by_district = budget_stats['user_count_by_district']
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
    if Rails.env.test? || Rails.env.development?
      @polls = ::Poll.current
    else
      @polls = ::Poll.where(starts_at: Time.parse('08-10-2017'), ends_at: Time.parse('22-10-2017'))
    end
    @participants = ::Poll::Voter.where(poll: @polls)
  end

  private

  def voters_in_heading(heading)
    Vote.where(votable_type: 'Budget::Investment').
        includes(:budget_investment).
        where(budget_investments: {heading_id: heading.id}).
        select("votes.voter_id").distinct.count
  end

  def voters_in_districts(budget)
    Vote.where(votable_type: 'Budget::Investment').
        includes(:budget_investment).
        where(budget_investments: { heading_id: (budget.heading_ids - [budget.city_heading.id]) }).
        select("votes.voter_id").distinct.count
  end

end
