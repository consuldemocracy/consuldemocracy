class Admin::StatsController < Admin::BaseController
  def show
    @event_types = Ahoy::Event.distinct.order(:name).pluck(:name)

    @visits    = Visit.count
    @debates   = Debate.with_hidden.count
    @proposals = Proposal.with_hidden.count
    @comments  = Comment.not_valuations.with_hidden.count

    @debate_votes   = Vote.count_for("Debate")
    @proposal_votes = Vote.count_for("Proposal")
    @comment_votes  = Vote.count_for("Comment")

    @votes = Vote.count

    @user_level_two   = User.active.level_two_verified.count
    @user_level_three = User.active.level_three_verified.count
    @verified_users   = User.active.level_two_or_three_verified.count
    @unverified_users = User.active.unverified.count
    @users = User.active.count

    @user_ids_who_voted_proposals = ActsAsVotable::Vote.where(votable_type: "Proposal")
                                                       .distinct
                                                       .count(:voter_id)

    @user_ids_who_didnt_vote_proposals = @verified_users - @user_ids_who_voted_proposals
    budgets_ids = Budget.where.not(phase: "finished").ids
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

  def budgets
    @budgets = Budget.all
  end

  def budget_supporting
    @budget = Budget.find(params[:budget_id])
  end

  def budget_balloting
    @budget = Budget.find(params[:budget_id])

    authorize! :read_admin_stats, @budget, message: t("admin.stats.budgets.no_data_before_balloting_phase")
  end

  def polls
    @polls = ::Poll.current
    @participants = ::Poll::Voter.where(poll: @polls)
  end

  def sdg
    @goals = SDG::Goal.order(:code)
  end
end
