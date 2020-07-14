class UserSegments
  SEGMENTS = %w[all_users
                administrators
                all_proposal_authors
                proposal_authors
                investment_authors
                feasible_and_undecided_investment_authors
                selected_investment_authors
                winner_investment_authors
                not_supported_on_current_budget].freeze

  def self.all_users
    User.active.where.not(confirmed_at: nil)
  end

  def self.administrators
    all_users.administrators
  end

  def self.all_proposal_authors
    author_ids(Proposal.pluck(:author_id))
  end

  def self.proposal_authors
    author_ids(Proposal.not_archived.not_retired.pluck(:author_id))
  end

  def self.investment_authors
    author_ids(current_budget_investments.pluck(:author_id))
  end

  def self.feasible_and_undecided_investment_authors
    unfeasible_and_finished_condition = "feasibility = 'unfeasible' and valuation_finished = true"
    investments = current_budget_investments.where.not(unfeasible_and_finished_condition)
    author_ids(investments.pluck(:author_id))
  end

  def self.selected_investment_authors
    author_ids(current_budget_investments.selected.pluck(:author_id))
  end

  def self.winner_investment_authors
    author_ids(current_budget_investments.winners.pluck(:author_id))
  end

  def self.not_supported_on_current_budget
    author_ids(
      User.where.not(
        id: Vote.select(:voter_id).where(votable: current_budget_investments).distinct
      )
    )
  end

  def self.user_segment_emails(users_segment)
    UserSegments.send(users_segment).newsletter.order(:created_at).pluck(:email).compact
  end

  private

    def self.current_budget_investments
      Budget.current.investments
    end

    def self.author_ids(author_ids)
      all_users.where(id: author_ids)
    end
end
