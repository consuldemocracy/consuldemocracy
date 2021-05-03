ActsAsVotable::Vote.class_eval do
  include Graphqlable

  belongs_to :signature
  belongs_to :budget_investment, foreign_key: "votable_id", class_name: "Budget::Investment"

  scope :public_for_api, -> do
    where(%{(votes.votable_type = 'Debate' and votes.votable_id in (?)) or
            (votes.votable_type = 'Proposal' and votes.votable_id in (?)) or
            (votes.votable_type = 'Comment' and votes.votable_id in (?))},
          Debate.public_for_api.pluck(:id),
          Proposal.public_for_api.pluck(:id),
          Comment.public_for_api.pluck(:id))
  end

  def self.for_debates(debates)
    where(votable_type: "Debate", votable_id: debates)
  end

  def self.for_proposals(proposals)
    where(votable_type: "Proposal", votable_id: proposals)
  end

  def self.for_legislation_proposals(proposals)
    where(votable_type: "Legislation::Proposal", votable_id: proposals)
  end

  def self.for_budget_investments(budget_investments = Budget::Investment.all)
    where(votable_type: "Budget::Investment", votable_id: budget_investments)
  end

  def self.for_comments(comments)
    where(votable_type: "Comment", votable_id: comments)
  end

  def value
    vote_flag
  end
end
