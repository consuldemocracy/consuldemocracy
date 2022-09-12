require_dependency Rails.root.join("app", "controllers", "admin", "stats_controller").to_s

class Admin::StatsController < Admin::BaseController
  def show
    @event_types = Ahoy::Event.pluck(:name).uniq.sort

    @visits    = Visit.count
    @debates   = Debate.with_hidden.count
    @proposals = Proposal.with_hidden.count
    @comments  = Comment.not_valuations.with_hidden.count

    @debate_votes   = Vote.where(votable_type: "Debate").count
    @proposal_votes = Vote.where(votable_type: "Proposal").count
    @comment_votes  = Vote.where(votable_type: "Comment").count

    @votes = Vote.count
    @physical_votes = PhysicalFinalVote.sum(:total_votes)

    @user_level_two   = User.active.level_two_verified.count
    @user_level_three = User.active.level_three_verified.count
    @verified_users   = User.active.level_two_or_three_verified.count
    @unverified_users = User.active.unverified.count
    @users = User.active.count

    @user_ids_who_voted_proposals = ActsAsVotable::Vote.where(votable_type: "Proposal")
                                                       .distinct
                                                       .count(:voter_id)

    @user_ids_who_didnt_vote_proposals = @verified_users - @user_ids_who_voted_proposals
    budgets_ids = Budget.where.not(phase: "finished").pluck(:id)
    @budgets = budgets_ids.size
    @investments = Budget::Investment.where(budget_id: budgets_ids).count

    # Número de votos del último presupuesto participativo
    last_budget = Budget.order(:created_at).last
    @last_budget_votes = last_budget.investments.map(&:ballot_lines_count).sum

    @phisical_votes_count = last_budget.investments.includes(:physical_final_votes).sum("physical_final_votes.total_votes")
    @vote_count = last_budget.lines.count + @phisical_votes_count                                                                                                

    # Número de votantes del último presupuesto participativo
    @last_budget_voters = Budget::Ballot::Line.where(budget: last_budget).to_a.uniq { |line| line.ballot.user_id }.count
  end
end
