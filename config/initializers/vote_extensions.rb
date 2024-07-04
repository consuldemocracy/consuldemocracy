Rails.application.reloader.to_prepare do
  ActsAsVotable::Vote.class_eval do
    include Graphqlable
  end
end

ActsAsVotable::Vote.class_eval do
  belongs_to :signature
  belongs_to :budget_investment, foreign_key: "votable_id", class_name: "Budget::Investment"

  scope :public_for_api, -> do
    where(votable: [Debate.public_for_api, Proposal.public_for_api, Comment.public_for_api])
  end

  def self.count_for(votable_type)
    where(votable_type: votable_type).count
  end

  def value
    vote_flag
  end
end
