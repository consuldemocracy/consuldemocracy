class UserSegments
  def self.all_users
    User.newsletter.active
  end

  def self.proposal_authors
    author_ids = Proposal.not_archived.not_retired.pluck(:author_id).uniq
    author_ids(author_ids)
  end

  def self.investment_authors
    author_ids = current_budget_investments.pluck(:author_id).uniq
    author_ids(author_ids)
  end

  def self.feasible_and_undecided_investment_authors
    author_ids = current_budget_investments.where(feasibility: %w(feasible undecided))
                                           .pluck(:author_id).uniq

    author_ids(author_ids)
  end

  def self.selected_investment_authors
    author_ids = current_budget_investments.selected.pluck(:author_id).uniq
    author_ids(author_ids)
  end

  def self.winner_investment_authors
    author_ids = current_budget_investments.winners.pluck(:author_id).uniq
    author_ids(author_ids)
  end

  private

  def self.current_budget_investments
    Budget.current.investments
  end

  def self.author_ids(author_ids)
    all_users.where(id: author_ids)
  end
end
